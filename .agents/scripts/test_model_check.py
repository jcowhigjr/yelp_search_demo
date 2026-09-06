#!/usr/bin/env python3
"""Regression tests for the git-safety guard in model_check.py.

Run with:  python3 -m unittest discover -s .agents/scripts -p 'test_*.py'
"""

import json
import io
import os
import sys
import unittest
from contextlib import redirect_stdout

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import model_check  # noqa: E402


def decision_for(command):
    """Run the PreToolUse handler and return its decision string."""
    payload = {"toolCall": {"name": "run_command", "args": {"CommandLine": command}}}
    buffer = io.StringIO()
    with redirect_stdout(buffer):
        model_check.handle_pre_tool_use(payload)
    return json.loads(buffer.getvalue())["decision"]


class BlanketStagingIsDenied(unittest.TestCase):
    def test_denies_blanket_add_forms(self):
        for command in [
            "git add .",
            "git add -A",
            "git add --all",
            "git add -u",
            "git add --update",
            "git add *",
            "git add :/",
            "git add -Av",
            "git -C /repo add .",
            "mise exec -- git add .",
            "sudo git add --all",
            "cd app && git add .",
            "git status\ngit add .",
        ]:
            with self.subTest(command=command):
                self.assertEqual(decision_for(command), "deny")

    def test_denies_blanket_pathspec_after_separator(self):
        # `--` marks the start of pathspecs; a blanket pathspec is still
        # blanket there and must not become an escape hatch.
        for command in ["git add -- .", "git add -- :/", "git add -- '*'"]:
            with self.subTest(command=command):
                self.assertEqual(decision_for(command), "deny")

    def test_denies_nested_shell_invocations(self):
        # The previous anchoring fix let these through.
        for command in ['sh -c "git add ."', "bash -c 'git add -A'"]:
            with self.subTest(command=command):
                self.assertEqual(decision_for(command), "deny")

    def test_denies_auto_commit_flags(self):
        for command in ["git commit -a", "git commit -am 'wip'", "git commit --all"]:
            with self.subTest(command=command):
                self.assertEqual(decision_for(command), "deny")


class ExplicitWorkIsAllowed(unittest.TestCase):
    def test_allows_explicit_staging(self):
        for command in [
            "git add docs/ROADMAP.md",
            "git add docs/ROADMAP.md .agents/skills/groom-backlog/SKILL.md",
            "git add -- docs/ROADMAP.md",
            "git commit -m 'feat: add roadmap'",
            "git push -u origin HEAD",
        ]:
            with self.subTest(command=command):
                self.assertEqual(decision_for(command), "allow")

    def test_allows_explicit_add_chained_with_push_upstream(self):
        # Regression: `.*?` used to scan past `git add` and match the `-u`
        # belonging to `git push`, blocking a legitimate command chain.
        command = (
            "git add docs/ROADMAP.md && git commit -m 'feat: roadmap' "
            "&& git push -u origin feature/groom-backlog-skill"
        )
        self.assertEqual(decision_for(command), "allow")

    def test_allows_hyphenated_words_in_commit_messages(self):
        # Regression: `-backlog` inside a quoted message matched the
        # `git commit -a` pattern, forcing messages to be reworded.
        command = 'git commit -m "feat: add /groom-backlog skill and ROADMAP.md template"'
        self.assertEqual(decision_for(command), "allow")

    def test_allows_git_add_mentioned_in_pull_request_body(self):
        # Regression: prose describing the rule tripped the rule.
        command = (
            'gh pr create --base develop --title "feat: groom backlog" '
            '--body "Reminder: never run git add . in this repo."'
        )
        self.assertEqual(decision_for(command), "allow")

    def test_allows_unrelated_commands(self):
        for command in ["ls -la", "mise run test", "echo git add ."]:
            with self.subTest(command=command):
                self.assertEqual(decision_for(command), "allow")


class MalformedInputFailsSafe(unittest.TestCase):
    def test_unbalanced_quotes_still_catch_blanket_add(self):
        # shlex cannot tokenize this; the regex fallback must still deny it.
        self.assertEqual(decision_for('git add . && echo "oops'), "deny")

    def test_non_command_tools_are_ignored(self):
        payload = {"toolCall": {"name": "read_file", "args": {"path": "git add ."}}}
        buffer = io.StringIO()
        with redirect_stdout(buffer):
            model_check.handle_pre_tool_use(payload)
        self.assertEqual(json.loads(buffer.getvalue())["decision"], "allow")


if __name__ == "__main__":
    unittest.main()
