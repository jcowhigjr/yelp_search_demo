## Context

The evergreen hardening work is merged, but post-release validation showed that workflow registration alone is not enough to prove the path works on GitHub. The repo now needs a lightweight, repeatable baseline review that compares declared Ruby and Rails versions with upstream releases and confirms that automation, manifests, and documentation still point at the intended upgrade tracks.

The current repo state already provides concrete review inputs:

- `mise.toml` and the Gemfiles declare Ruby `3.3.10`
- the Rails next lane currently targets `>= 8.1.0.beta1, < 8.2`
- upstream has Ruby `3.3.11` available in the same minor line
- upstream has Rails `8.1.3` as the latest stable release

## Goals / Non-Goals

**Goals:**
- Define a standard review cycle for Ruby and Rails baselines.
- Enumerate the repo surfaces that must remain consistent during the review.
- Separate baseline confirmation from actual upgrade promotion or merge decisions.
- Make the review output actionable for future evergreen PRs and issue triage.

**Non-Goals:**
- Automatically changing production versions as part of the review.
- Replacing `next_rails` or redesigning the evergreen workflows in this change.
- Deciding the final adoption timing for Ruby minor upgrades or future Rails prereleases.

## Decisions

### Review both declared versions and automation targets
The baseline review will compare both source-of-truth declarations and automation behavior. This is necessary because a repo can declare one version while the evergreen jobs or docs imply a different target.

Alternative considered: only reviewing `mise.toml` and `Gemfile`. Rejected because it would miss drift in workflow config and upgrade documentation.

### Split stable and prerelease tracks
The review will evaluate stable Ruby/Rails release lines separately from the prerelease Rails next lane. This preserves the repo's current dual-boot strategy and avoids conflating production adoption with compatibility monitoring.

Alternative considered: one combined upgrade recommendation. Rejected because stable adoption and prerelease validation have different risk profiles and owners.

### Treat review output as evidence, not an implicit approval
The change will define required evidence and decision points, but it will not auto-authorize upgrades. This keeps the review useful even when the best next step is "stay where we are."

Alternative considered: using the review to directly trigger upgrade PRs. Rejected because that belongs in the promotion-path change.

## Risks / Trade-offs

- [Review becomes stale quickly] -> Mitigation: define a repeatable cadence and explicit upstream comparison inputs.
- [Docs and automation drift independently] -> Mitigation: require the review to inspect manifests, workflows, and docs together.
- [Baseline review gets mistaken for an upgrade commitment] -> Mitigation: explicitly separate review outcomes from promotion decisions.

## Migration Plan

1. Add baseline-review requirements and tasks to OpenSpec.
2. Use the change to drive the corresponding GitHub issue scope.
3. Implement the documented review process in repo docs and evergreen maintenance checklists.
4. Feed the review output into future upgrade PRs or promotion decisions as separate follow-up work.

## Open Questions

- What review cadence is appropriate for this repo: scheduled monthly, release-driven, or issue-driven?
- Should the baseline review record upstream release URLs directly in repo docs or only in issue comments?
