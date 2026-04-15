# Governance Contract

Version: 2026-03-30

This file defines the repository's explicit AI governance contract. It is intended to be self-contained so any agent operating in this repo can follow the same risk, scope, and verification rules even without a separate global setup.

## Quick Reference

Use these commands first when orienting in the repo:

```bash
./scripts/git-sync.sh
mise exec -- git status --short --branch
mise exec -- git log --oneline --decorate --graph -10
mise exec -- bin/rails db:version
```

Use the smallest relevant validation command before handoff:

```bash
mise run test
mise run test-system
mise run brakeman
```

## Preflight Classification

Before any meaningful code, config, data, or workflow mutation, classify the work:

- `SAFE`: low-risk, in-scope work; proceed
- `WARN`: a governance rule is at risk; warn before proceeding
- `BLOCKED`: explicit approval is required before acting
- `AMBIGUOUS`: information is missing; clarify or discover it before acting

Do not bury the classification in internal reasoning when a rule is triggered. Surface it.

## Warning Format

When a rule is triggered, use this format before continuing:

```text
GOVERNANCE WARNING
Rule at risk: <RULE_NAME>
Why: <specific risk in this session>
Safer path: <specific alternative available now>
Approval phrase: `acknowledge <RULE_NAME>: <reason>`
```

## Hard Limits

The following actions require explicit user approval in the current session:

- production mutations
- destructive or irreversible operations
- database schema or persistent data operations with non-trivial blast radius
- secrets, auth, credentials, tokens, or permission broadening
- bypassing existing tests, smoke checks, hooks, or required validation
- work that expands beyond the stated task or linked issue scope

The following actions are never acceptable:

- committing or printing secrets into tracked files, logs, or comments
- using `--no-verify` to bypass repo hooks without explicitly following a documented emergency workflow, calling out the bypass, and running the skipped checks as soon as possible
- pretending verification ran when it did not

## Rules

- `PROD_GATE`: No production-impacting mutation without explicit approval.
- `DESTRUCTIVE_GATE`: No irreversible destructive action without explicit approval.
- `SECRET_GATE`: Never expose, print, move, or commit secrets or credential material.
- `TEST_GATE`: Do not bypass existing validation expectations without calling it out.
- `SCOPE_GATE`: Do not expand beyond the stated request or issue without flagging it first.
- `VERIFY_BEFORE_FINISH`: Do not claim success without appropriate verification; if validation could not run, state that clearly.
- `DISCOVER_DONT_ASK`: Prefer local discovery and existing repo context over asking the user for information that can be verified directly.
- `SINGLE_ESCALATION`: Prefer one escalation path at a time for a given blocker instead of stacking tools, humans, and fallback loops simultaneously.

## Phase Transition Re-Checks

Re-run the classification whenever work moves between phases:

- planning to implementation
- implementation to verification
- verification to commit, push, PR, or deploy actions

If the blast radius has changed, treat that as a fresh governance check.

## Review and Automation Reporting

When an automated review, briefing, or planning artifact is generated, include a `## Governance Flags` section if any rule was triggered. For each flag, list:

- rule name
- trigger reason
- resolution, deferral, or required approval

If no governance rule was triggered, do not add a filler section.

## Enforcement Preference

When possible, encode critical rules in:

- tests
- hooks
- CI
- branch protections

Prompt guidance is advisory unless a rule explicitly blocks execution.
