# Agents: No-Toil Dependabot Automation (One-Pass)

Use this quick checklist when eliminating manual Dependabot toil.

## TL;DR checklist
- Auto-approve + auto-merge (squash) all Dependabot PRs after checks pass
- Weekly, grouped Dependabot updates to reduce PR noise
- Scheduled refresher to comment `@dependabot recreate` on stale PRs and re-queue auto-merge
- Make `bin/setup` lefthook install resilient (fallback to `bundle exec`)
- Ensure `lefthook` is available in CI (`Gemfile` group :development, :ci)

## One-pass task spec (copy/paste into an issue/PR description)
- Repo: owner=jcowhigjr repo=yelp_search_demo
- Branch: chore/ci-dependabot-automation (or current feature branch)
- Do exactly the following in one PR:
  1) Update `.github/workflows/auto-approve.yml` to:
     - approve Dependabot PRs; enable `gh pr merge --auto --squash $PR_NUMBER`
     - condition `if: github.actor == 'dependabot[bot]'`
  2) Add `.github/dependabot.yml` with:
     - interval: weekly (Sunday, 07:00 PT)
     - groups: rubocop-suite, rails-ecosystem, dev-tools, test-stack, perf-and-runtime, patch-and-minor
  3) Add `.github/workflows/dependabot-refresh.yml` to:
     - detect stale Dependabot PRs (>=25 days or auto-rebase disabled notice)
     - comment `@dependabot recreate`
     - re-enable auto-merge (squash)
  4) Harden `bin/setup` for lefthook:
     - try `lefthook install`, fallback to `bundle exec lefthook install`, else skip
  5) Ensure `Gemfile` includes `lefthook` in `group :development, :ci`
  6) Commit, push, open PR to `develop`, enable auto-merge (squash)
  7) Verify: pre-push hooks pass; PR URL posted; auto-merge queued

## CLI snippets (manual fallback)
- List Dependabot PRs:
  - `gh pr list --author "dependabot[bot]" --json number --jq '.[].number'`
- Refresh and queue auto-merge for each `<num>`:
  - `gh pr comment <num> -b "@dependabot recreate"`
  - `gh pr merge --auto --squash <num>`

## Notes
- Requires: repo “Allow auto-merge” enabled; Actions `GITHUB_TOKEN` has PR write perms
- Branch protection: required checks must pass for auto-merge to execute
- Run this reminder anytime: `lefthook run workflow-status`