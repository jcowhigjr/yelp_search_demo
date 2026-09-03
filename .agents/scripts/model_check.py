#!/usr/bin/env python3
"""
Antigravity Lifecycle Hook Helper for yelp_search_demo.

Handles:
1. PreInvocation: Tracks active model. If model changes or is new, injects
   an ephemeral prompt reminding the agent to refresh capabilities and repo best practices.
2. PreToolUse: Guardrail preventing 'git add .' or 'git add --all' in run_command tool calls.
"""

import sys
import json
import os
import re

AGENT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_STAMP_FILE = os.path.join(AGENT_DIR, ".active_model")

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

        # Comprehensive forbidden patterns catching:
        # 1. git add with ., *, -A, --all, -u, --update, :, :/ with quotes and delimiters
        # 2. git commit with -a or -am flags
        forbidden_patterns = [
            r"\bgit\s+(?:-[^\s]+\s+)*add\b.*?(?:(?<=[\s'\"`])|^)(?:['\"`]?)(?:\.|\*|-A|--all|--update|-u|:\/?)(?:['\"`]?)(?=(?:[\s;&|'\"`]|[\),>]|$))",
            r"\bgit\s+(?:-[^\s]+\s+)*commit\b.*?-[a-zA-Z]*a[a-zA-Z]*\b"
        ]
        for pattern in forbidden_patterns:
            if re.search(pattern, cmd):
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
