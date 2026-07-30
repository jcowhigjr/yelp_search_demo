# Dependabot Auto-Merge Contract

## Goal

Safe Dependabot updates should merge after required tests and CodeQL pass, without weakening the
manual review policy for riskier updates.

The repository uses one workflow for merge eligibility:
`.github/workflows/auto-approve.yml`.

## Automatic policy

The workflow queues GitHub auto-merge for:

- patch updates for any dependency type
- minor updates whose Dependabot metadata classifies them as development dependencies

The workflow leaves these updates for manual review:

- major updates
- minor production or indirect dependency updates
- updates with missing or unrecognized metadata

The `develop` ruleset remains the enforcement layer. Auto-merge cannot complete until the required
`test` status, code-scanning requirements, branch freshness, and conversation-resolution rules are
satisfied.

## Workflow ownership

### Queue safe Dependabot PRs

`.github/workflows/auto-approve.yml` runs on `pull_request_target` for Dependabot-authored PRs. It
uses `dependabot/fetch-metadata` to classify the update and `gh pr merge --auto --squash` to queue
eligible updates.

It deliberately does not use `workflow_run` or `pull_request` fallback triggers. Those triggers
previously caused missing event payloads, duplicate runs, duplicate approvals, and runs requiring
manual workflow approval.

The workflow sets `GH_REPO`, so GitHub CLI commands do not depend on a checkout. This avoids both
the historical `not a git repository` failure and the security risk of checking out PR code in a
privileged `pull_request_target` job.

### Refresh branches after `develop` changes

`.github/workflows/auto-update-prs.yml` updates only same-repository PRs whose
`mergeStateStatus` is `BEHIND`.

Before updating a branch, it records whether GitHub auto-merge was already queued. GitHub can clear
auto-merge when another actor updates the PR branch, so the workflow restores only that existing
request after the new head commit appears. It never turns a manual PR into an automatic one.

The workflow then dispatches the main CI workflow for the updated head. Branch-update and CI
dispatch failures are not hidden.

### Refresh stale Dependabot PRs

`.github/workflows/dependabot-refresh.yml` runs every six hours. It comments
`@dependabot recreate` only when a PR is at least 25 days old or Dependabot reports that automatic
rebases are disabled.

The refresh workflow does not decide merge eligibility and does not call `gh pr merge`. A recreated
PR produces a normal Dependabot event, allowing the single eligibility workflow to re-evaluate it.

## Why this structure exists

Several historical fixes addressed individual symptoms:

- #795 / PR #796 consolidated duplicate merge logic after CodeQL integration.
- PR #872 added grouped updates and stale-PR recovery.
- #891 / PR #892 removed a `workflow_run` dependency that prevented CI on updated commits.
- PR #1024 later added a second auto-merge workflow, recreating duplicate ownership.
- #1071 / PR #1072 added overlapping event fallbacks and branch-update logic.
- #2314 / PR #2305 repaired workflow startup, but a missing checkout still caused a runtime
  failure.

Issue #1225 tracks the current end-to-end contract.

## Verification

Run the workflow contract test:

```bash
mise exec -- bin/rails test test/integration/dependabot_workflow_configuration_test.rb
```

Validate all workflow YAML with the repository lint task or `actionlint` when available. After a
workflow PR merges, keep #1225 open until a real safe Dependabot patch PR proves this sequence:

1. Dependabot opens or synchronizes the PR.
2. `Queue safe Dependabot PRs` succeeds and `autoMergeRequest` is present.
3. The required `test` and CodeQL checks pass on the current head.
4. If `develop` changes first, the branch refresh restores the existing auto-merge request.
5. The PR merges without manual intervention.

## Troubleshooting

- `test` is missing: inspect the main CI dispatch and current PR head SHA.
- `autoMergeRequest` is absent on a safe update: inspect `Queue safe Dependabot PRs`.
- Auto-merge disappears after a base update: inspect `Auto-update PRs` and confirm it recorded
  `autoMergeRequest` before updating the branch.
- A stale PR is not recreated: inspect `Refresh stale Dependabot PRs`; failures should make the
  workflow red rather than being reported as success.
- A major or production minor update is queued: treat this as a policy regression and disable
  auto-merge on that PR.

Manual fallback for an individually reviewed PR:

```bash
gh pr merge --auto --squash <PR_NUMBER>
```
