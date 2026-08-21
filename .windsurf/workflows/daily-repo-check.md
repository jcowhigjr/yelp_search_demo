---
description: Daily repo supervisor pass - open PRs, pipeline health, production status, memory hygiene
---

Run the daily repository supervisor pass. Be terse; report only what needs attention. All gh/git commands must be run via `mise exec --` and kept to a single line each.

1. Check open PRs and their health.
// turbo
2. Run: mise exec -- git fetch origin --prune && gh pr list --state open --json number,title,author,mergeStateStatus,autoMergeRequest,createdAt --jq '.[] | "#\(.number) \(.title) | \(.author.login) | \(.mergeStateStatus) | autoMerge=\(.autoMergeRequest != null) | \(.createdAt)"'
3. Flag: any PR with autoMerge=true and mergeStateStatus=BEHIND (stranded - see issue #2996). Flag Dependabot PRs open > 24h. Flag any PR with a failing required `test` check (use `gh pr checks <n>` sparingly).

4. Check CI and smoke health on develop.
// turbo
5. Run: gh run list --branch develop --limit 10 --json workflowName,conclusion,createdAt --jq '.[] | "\(.createdAt) \(.workflowName): \(.conclusion)"' | sort -r | head -10
6. Flag the latest run of `Production Smoke Check` or `main.yml` if its conclusion is failure.
// turbo
7. Run: curl -s -o /dev/null -w "%{http_code}" --max-time 15 https://dorkbob.herokuapp.com/healthz
8. Flag if not 200.

9. Check memory hygiene: review MEMORY entries touched this week for stale or contradicted claims; correct or delete them. Validate any new relations before saving.

10. Report a concise digest: PRs needing action, failing automation, prod status. Propose fixes; ask before any production-impacting or ruleset-impacting change. Update the todo list with anything actionable.
