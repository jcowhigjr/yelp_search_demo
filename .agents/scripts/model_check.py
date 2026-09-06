#!/usr/bin/env python3
"""
Antigravity Lifecycle Hook Helper for yelp_search_demo.

Handles:
1. PreInvocation: Tracks active model. If model changes or is new, injects
   an ephemeral prompt reminding the agent to refresh capabilities and repo best practices.
2. PreToolUse: Guardrail preventing blanket staging ('git add .', '-A', '-u') and
   auto-commits ('git commit -a') in run_command tool calls.
"""

import sys
import json
import os
import re
import shlex

AGENT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_STAMP_FILE = os.path.join(AGENT_DIR, ".active_model")

# --- Git safety guard -------------------------------------------------------
#
# The guard used to be a pair of regexes run against the whole command line.
# That was wrong in both directions:
#   * false positives - `.*?` scanned past the end of the `git add` command and
#     matched the `-u` in a later `git push -u origin`, and any `-a`-containing
#     word inside a quoted `-m` message looked like `git commit -a`.
#   * false negatives - anchoring the pattern to `^|&&|;|\|` (an attempted fix)
#     let `git add .` slip through after a newline or inside `sh -c "..."`.
#
# We now tokenize the command with shlex and inspect real argv positions, so a
# quoted message is a single opaque token and flags are only read where flags
# actually live. Unparseable input falls back to the conservative regexes.

SHELL_SEPARATORS = frozenset({"&&", "||", ";", "|", "&"})

# Shells whose `-c` argument is a nested command line worth re-scanning.
SHELL_COMMANDS = frozenset({"sh", "bash", "zsh", "dash", "ksh"})

# Commands whose arguments are arbitrary prose, not nested shell commands.
# Without this, `echo git add .` would be denied.
TEXT_ONLY_COMMANDS = frozenset({"echo", "printf", "cat"})

# `git add` arguments that stage more than an explicit path.
BLANKET_ADD_ARGS = frozenset({".", "*", "-A", "--all", "-u", "--update", ":", ":/"})

# git's own global options that consume the following token.
GIT_GLOBAL_VALUE_OPTS = frozenset({"-C", "-c", "--git-dir", "--work-tree", "--namespace", "--exec-path"})

# `git commit` options that consume the following token, so that a value such
# as `-m "-a rushed message"` is never mistaken for the `-a` flag.
COMMIT_VALUE_OPTS = frozenset({
    "-m", "--message", "-F", "--file", "-C", "--reuse-message",
    "-c", "--reedit-message", "--author", "--date", "-S", "--gpg-sign",
    "--fixup", "--squash", "--cleanup", "--pathspec-from-file",
})

FALLBACK_PATTERNS = (
    r"\bgit\s+(?:-[^\s]+\s+)*add\b[^;&|\n]*?(?<=[\s'\"`])(?:['\"`]?)(?:\.|\*|-A|--all|--update|-u|:\/?)(?:['\"`]?)(?=(?:[\s;&|'\"`]|[\),>]|$))",
    r"\bgit\s+(?:-[^\s]+\s+)*commit\b[^;&|\n]*?(?<=[\s'\"`])-[a-zA-Z]*a[a-zA-Z]*\b",
)


def _split_segments(tokens):
    """Group a flat token list into per-command segments on shell separators."""
    segments = []
    current = []
    for token in tokens:
        if token in SHELL_SEPARATORS:
            if current:
                segments.append(current)
            current = []
        else:
            current.append(token)
    if current:
        segments.append(current)
    return segments


def _git_argv(segment):
    """Return the argv slice following `git`, skipping any wrapper prefix.

    Scanning for the `git` token (rather than requiring it first) transparently
    handles `FOO=bar git ...`, `sudo git ...`, and `mise exec -- git ...`.
    """
    if segment and segment[0] in TEXT_ONLY_COMMANDS:
        return None
    for index, token in enumerate(segment):
        if token == "git" or token.endswith("/git"):
            return segment[index + 1:]
    return None


def _skip_git_global_opts(argv):
    index = 0
    while index < len(argv) and argv[index].startswith("-"):
        if argv[index] in GIT_GLOBAL_VALUE_OPTS:
            index += 2
        else:
            index += 1
    return index


def _add_violation(args):
    for arg in args:
        if arg == "--":
            break
        if arg in BLANKET_ADD_ARGS:
            return True
        # Bundled short flags such as `-Av` or `-nu`.
        if arg.startswith("-") and not arg.startswith("--") and len(arg) > 1:
            if "A" in arg[1:] or "u" in arg[1:]:
                return True
    return False


def _commit_violation(args):
    index = 0
    while index < len(args):
        arg = args[index]
        if arg == "--":
            break
        if arg in COMMIT_VALUE_OPTS:
            index += 2
            continue
        if arg == "--all":
            return True
        if arg.startswith("--"):
            index += 1
            continue
        if arg.startswith("-") and len(arg) > 1 and "a" in arg[1:]:
            return True
        index += 1
    return False


def _nested_command(segment):
    """Return a shell's `-c` argument, which is itself a command line.

    Only shell invocations qualify. Recursing into every whitespace-bearing
    token would re-flag prose such as a `gh pr create --body` that merely
    mentions `git add .`.
    """
    for index, token in enumerate(segment):
        if token in SHELL_COMMANDS:
            for candidate in range(index + 1, len(segment) - 1):
                if segment[candidate] == "-c":
                    return segment[candidate + 1]
            return None
    return None


def _scan_tokens(tokens, depth=0):
    """True when any command segment stages or commits in blanket form."""
    for segment in _split_segments(tokens):
        argv = _git_argv(segment)
        if argv is not None:
            offset = _skip_git_global_opts(argv)
            if offset < len(argv):
                subcommand = argv[offset]
                args = argv[offset + 1:]
                if subcommand == "add" and _add_violation(args):
                    return True
                if subcommand == "commit" and _commit_violation(args):
                    return True

        # Recurse into nested command strings, e.g. `sh -c "git add ."`.
        nested = _nested_command(segment) if depth < 3 else None
        if nested and _violates_git_safety(nested, depth + 1):
            return True
    return False


def _violates_git_safety(cmd, depth=0):
    if not cmd or "git" not in cmd:
        return False
    for line in cmd.splitlines():
        if "git" not in line:
            continue
        try:
            lexer = shlex.shlex(line, posix=True, punctuation_chars=True)
            lexer.whitespace_split = True
            tokens = list(lexer)
        except ValueError:
            # Unbalanced quotes - fall back to the conservative regexes rather
            # than letting a malformed command through unchecked.
            if any(re.search(pattern, line) for pattern in FALLBACK_PATTERNS):
                return True
            continue
        if _scan_tokens(tokens, depth):
            return True
    return False


def handle_pre_invocation(payload):
    # Defensive key lookup across Antigravity, IDE, and MCP schema variants
    model_name = (
        payload.get("modelName")
        or payload.get("model")
        or payload.get("model_name")
        or ""
    ).strip()

    if not model_name:
        print(json.dumps({}))
        return

    previous_model = ""
    if os.path.exists(MODEL_STAMP_FILE):
        try:
            with open(MODEL_STAMP_FILE, "r", encoding="utf-8") as f:
                previous_model = f.read().strip()
        except Exception:
            previous_model = ""

    if model_name != previous_model:
        try:
            with open(MODEL_STAMP_FILE, "w", encoding="utf-8") as f:
                f.write(model_name)
        except Exception:
            pass

        refresher_msg = (
            f"[Antigravity Notice] Active model detected: '{model_name}'. "
            f"If starting a new conversation or if the model recently changed, "
            f"provide the user a quick confidence check & capability refresher for yelp_search_demo: "
            f"1) Confirm toolchain (mise exec --), "
            f"2) Confirm git safety (explicit staging, never 'git add .'), "
            f"3) Confirm testing suites (mise run test, mise run test-system), and "
            f"4) Calibrate recommended reasoning effort (Medium for routine fixes, High for architecture/refactors)."
        )

        output = {
            "injectSteps": [
                {
                    "ephemeralMessage": refresher_msg
                }
            ]
        }
        print(json.dumps(output))
    else:
        print(json.dumps({}))

def handle_pre_tool_use(payload):
    tool_call = payload.get("toolCall", {})
    tool_name = tool_call.get("name", "")
    args = tool_call.get("args", {})

    if tool_name == "run_command":
        cmd = args.get("CommandLine") or args.get("command") or args.get("cmd") or ""

        if _violates_git_safety(cmd):
            output = {
                "decision": "deny",
                "reason": (
                    "CRITICAL REPO RULE VIOLATION: You cannot use blanket staging ('git add .', '-A', '*', '-u', ':/') "
                    "or auto-committing ('git commit -a'). "
                    "Always stage specific, individual file paths (e.g., 'git add <path>') to prevent "
                    "accidentally staging untracked files or worktree noise."
                )
            }
            print(json.dumps(output))
            return

    output = {"decision": "allow"}
    print(json.dumps(output))

def main():
    try:
        raw_input = sys.stdin.read()
        payload = json.loads(raw_input) if raw_input else {}
    except Exception:
        payload = {}

    if "--pre-invocation" in sys.argv:
        handle_pre_invocation(payload)
    elif "--pre-tool-use" in sys.argv:
        handle_pre_tool_use(payload)
    else:
        print(json.dumps({}))

if __name__ == "__main__":
    main()
