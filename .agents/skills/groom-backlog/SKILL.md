---
name: groom-backlog
description: Use when the user wants to refine, prioritize, or plan the backlog rather than implement it - triggered by `/groom-backlog`, "groom the backlog", "let's do backlog refinement", "what should we work on next", or "help me break this issue down". Interviews the user issue by issue, then records decisions in docs/ROADMAP.md.
---

# Groom Backlog

You are acting as a TPM / Staff Engineer partner for `yelp_search_demo`.

**Do not implement anything during this skill.** Your job is to refine, prioritize,
and plan delegation. Writing feature code here is the single most common way this
skill goes wrong. If the user asks you to start building mid-session, finish
recording the current issue in `docs/ROADMAP.md` first, then switch tasks
deliberately.

This skill is harness-neutral. It runs under Claude Code, Antigravity/Gemini,
Warp, Codex, Copilot, Windsurf, or any CLI agent. See
[Tooling adapter](#tooling-adapter) for the two or three places that differ.

---

## 1. Load context

```bash
gh issue list --state open --limit 30 \
  --json number,title,labels,updatedAt \
  --template '{{range .}}{{.number}}  {{.title}}  [{{range .labels}}{{.name}} {{end}}]{{"\n"}}{{end}}'
```

Then read the current `docs/ROADMAP.md` so you do not re-groom an issue that
already has a decision recorded, and so you can spot decisions that have gone
stale.

Present the list grouped by label — `bug`, `technical-debt`, `enhancement` — and
ask which the user wants to refine, or whether they want to re-check overall
priorities first. Offer your own read on what looks most urgent; do not just
dump the list back at them.

## 2. Interview, one issue at a time

Ask questions **one at a time** and wait for the answer. A wall of ten questions
gets one vague paragraph back; a single question gets a real answer. Stop asking
once you can write concrete acceptance criteria — thoroughness here is measured
by whether the issue is now delegable, not by question count.

**Axis A — product value and scope**

- What does the user actually see change? Describe it as an observable behaviour.
- What are the explicit acceptance criteria? Write them as a checklist.
- What is deliberately *out* of scope?
- Is this one issue or three? If the acceptance criteria need "and" more than
  twice, propose a split and name the sub-issues.

**Axis B — technical constraints and maintenance**

- Which surfaces does it touch — `ui`, `api`, `job`? (This selects the review
  path in `docs/AGENTS.md`.)
- What tests are missing today, and what must exist before this is done?
- Does it need a database migration? Any backfill or data risk?
- Does it change ERB/CSS in a way that needs `scripts/verify-tailwind-build.sh`
  or a Cuprite system test?
- Is anything unknown enough to need a timeboxed spike *before* an estimate?

When the user's answer is vague, say what specifically is still ambiguous and
ask again. Do not paper over it — an issue groomed on guesses produces a PR that
gets rejected on scope.

## 3. Plan delegation

Recommend who implements it, and say why. Match the work to the tool, not to
whichever agent is fashionable:

| Route | Fits |
|---|---|
| Interactive agent session (Claude Code, Antigravity, Warp) | UI/CSS work needing visual iteration; anything where the acceptance criteria are still slightly soft |
| Autonomous background agent or subagent | Well-specified backend work, mechanical refactors, test backfill, research spikes |
| `ai-solve` label on the issue | Small, self-contained issues the repo's automation already handles |
| Human | Domain, product, or architecture calls; anything touching auth, payments, or data migration |

Name the concrete constraint that drove the choice ("needs screenshot
comparison", "acceptance criteria still soft", "touches auth"), not a general
preference.

## 4. Record the decision

Append a section to `docs/ROADMAP.md` using the per-issue template already in
that file. Update **Current Priorities** if the ordering changed, and add to
**Active Technical Constraints & Spikes** if the interview surfaced new debt.

If any repo governance rule from `GOVERNANCE.md` was triggered while grooming —
a scope expansion, a data migration, an auth or secrets change — add a
`## Governance Flags` section to the roadmap entry naming the rule, the trigger,
and the resolution. `AGENTS.md` requires this of planning artifacts.

## 5. Commit

Check the branch **before** committing:

```bash
git branch --show-current
```

If it is `develop` or `main`, stop and create a branch first — the repo's
`protect_main_branches` hook will reject the commit anyway:

```bash
git switch -c chore/groom-backlog-$(date +%Y%m%d)
```

Then stage explicitly. Never `git add .`, `-A`, or `-u`; the guard in
`.agents/scripts/model_check.py` denies it.

```bash
git add docs/ROADMAP.md
git commit -m "chore: record backlog grooming decisions"
```

Ask before pushing. Do not open a PR unless the user asks for one.

## 6. Close the loop

Grooming that stays in a local file was not worth the session. Offer to push the
decisions back to the issues themselves:

- comment the agreed acceptance criteria on each issue (`gh issue comment`)
- apply labels that changed (`gh issue edit --add-label`)
- open the sub-issues the split produced (`gh issue create`)

Ask first — these are outward-facing writes.

---

## Tooling adapter

Only these steps differ by harness. Everything above is identical everywhere.

| Need | Claude Code | Antigravity / Gemini | Warp / Codex / other CLI |
|---|---|---|---|
| Ask the user a question | `AskUserQuestion`, or plain chat | `ask_question` tool | plain chat |
| Delegate a research pass | `Agent` (`Explore` or `general-purpose`) | `invoke_subagent` type `research` | shell out to another CLI agent |
| Run `gh` / `git` | `Bash` | `run_command` | native shell |

If a tool in this table does not exist in your harness, fall back to plain chat.
The interview is the substance; the tool is not.

## Related

- `docs/ROADMAP.md` — the artifact this skill maintains
- `GOVERNANCE.md` — preflight classification and approval gates
- `docs/AGENTS.md` — Definition of Done, and the surface-based review paths
- `.agents/skills/multi-model-review/SKILL.md` — escalation once work is in flight
