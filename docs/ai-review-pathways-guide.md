# AI Review Pathways & Cross-Model Audit Guide

This document catalogs all available methods for obtaining an AI code or configuration review in this repository (`yelp_search_demo`), including their operational modes, authentication requirements, current status, and troubleshooting procedures.

---

## Summary Matrix of Review Pathways

| Pathway | CLI Command / Surface | Model(s) | Auth Mechanism | Current Operational Status |
| :--- | :--- | :--- | :--- | :--- |
| **Warp Agent** | Interactive Terminal (Warp) / `warp` | **Claude 3 Opus** (planning)<br>Claude 3.5 Sonnet (coding) | Chrome Browser OAuth (2 steps) | **Active & Ready** (User logged into Chrome & Warp open in terminal) |
| **Codex CLI** | `agent codex review --uncommitted` | **GPT-5.6-Luna** / `o3` | ChatGPT token / `~/.codex/auth.json` | **Rate-Limited** (ChatGPT limit resets periodically) |
| **Claude CLI** | `claude -p --model opus` or `agent claude` | **Claude 3 Opus** / Claude 3.5 Sonnet | Claude OAuth (`~/.claude/`) | **Needs Re-Auth** (Token revoked; requires `claude auth login`) |
| **Antigravity Subagent** | `invoke_subagent` (research/self) | **Gemini 3.8 Flash** / Gemini Pro | Antigravity Platform Session | **Fully Operational & Automated** |
| **Cross-Model Prompts** | `scripts/generate-cross-model-prompt.sh` | Any external LLM (Web/API) | None (generates Markdown text) | **Operational** |
| **PR Review Loop** | `./scripts/review-loop.sh` | Multi-agent (Claude/Codex/Human) | GitHub CLI (`gh`) / GitHub MCP | **Operational on open PR branches** |

---

## 1. Warp Agent Review (Claude 3 Opus)

The user's local Warp configuration (`~/.warp/ai_preferences.yaml`) designates:
* `ai.models.planning: "claude-3-opus"`
* `ai.models.coding: "claude-3-5-sonnet"`

### Modes & Usage in Interactive Warp:
1. **Interactive Review Prompt**:
   In your open Warp terminal window, activate Warp AI / Agent mode and paste:
   ```text
   Review all uncommitted changes in this repository.
   Focus on GEMINI.md, .agents/hooks.json, .agents/scripts/model_check.py,
   .agents/rules/, agent.prompt.yml, and docs/gemini-3.8-user-prompting-guide.md.
   Evaluate safety guardrails (git add . denial), model change tracking,
   and consistency with AGENTS.md and Rails 8 conventions.
   ```
2. **Re-authenticating Warp OAuth (if prompted)**:
   - Warp prompts to authenticate via Chrome.
   - Since Chrome is already logged in, click "Authorize" (takes 2 clicks/steps).
   - Warp immediately proceeds with Claude 3 Opus planning/review.

---

## 2. Codex CLI Review (`agent codex review`)

Codex is accessible via the workstation's unified `agent` wrapper (`/Users/temp/.local/bin/agent`).

### Modes:
* **Review Uncommitted Changes**:
  ```bash
  agent codex review --uncommitted
  ```
* **Review Against a Base Branch**:
  ```bash
  agent codex review --base develop
  ```
* **Custom Instructions via Stdin**:
  ```bash
  echo "Audit AI rules and hooks for security and syntax" | agent codex review -
  ```

### Current Status & Troubleshooting:
* If Codex reports `ERROR: You've hit your usage limit. Upgrade to Pro... or try again at <time>`, allow the rate-limit window to reset, or pass alternative API keys via `-c model=...`.

---

## 3. Claude Code CLI Review (`claude`)

Located at `/Users/temp/.local/bin/claude` (version 2.1.259).

### Modes:
* **Headless Print Mode**:
  ```bash
  claude -p --model opus "Review the uncommitted diff in this repo against AGENTS.md"
  ```
* **Ultrareview (Multi-Agent Cloud Review)**:
  ```bash
  claude ultrareview
  ```

### Resolving "OAuth access token has been revoked":
1. Run in an interactive shell:
   ```bash
   claude auth login
   ```
2. Confirm the browser prompt in Chrome (2 steps to re-authorize).
3. Verify status:
   ```bash
   claude auth status
   ```

---

## 4. Antigravity In-Tool Subagent Review

Inside Google Antigravity, you do not need to leave the session or install secondary credentials. You can trigger an independent audit subagent directly using `invoke_subagent` targeting either the `research` or `self` subagent types. The subagent inspects files, runs static validation tests, and reports findings back asynchronously.
