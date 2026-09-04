---
name: multi-model-review
description: |
  Skill to orchestrate multi-model review and escalation hierarchy for code changes.
  Provides guidance on using Warp (Claude), in‑situ subagents, and CLI reviewers.
  Includes re‑authentication steps for Claude OAuth.
---

## Usage

- **Warp Agent**: `warp` with Claude 3 Opus – run `warp review` (configured in `~/.warp/ai_preferences.yaml`).
- **In‑situ Subagent**: `invoke_subagent` with type `research` and prompt `Please perform an independent code review of the latest changes.`

- **CLI Reviewers**:
  - Codex: `mise exec -- agent codex review --uncommitted`
  - Claude: `mise exec -- claude -p --model opus`

## Re‑authentication (Claude)

If you encounter `401 OAuth access token has been revoked`:
```bash
mise exec -- claude auth login
```
Follow the two‑step Chrome approval.

## Escalation Order
1. **Warp Agent** – fast interactive review.
2. **Subagent Review** – automated safety check.
3. **CLI Reviewers** – external model audit.
4. **Human Review** – final PR approvals.
