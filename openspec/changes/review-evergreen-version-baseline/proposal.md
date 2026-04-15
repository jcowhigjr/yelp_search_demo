## Why

The evergreen workflows are now in place, but the repo still needs a repeatable way to confirm that its Ruby and Rails targets remain current and aligned with project policy. A dedicated baseline-review change is needed now because the post-release check already showed runtime gaps in the automation, and the repo's declared versions are behind the latest upstream patch and stable releases.

## What Changes

- Define a repeatable review process for comparing repo-declared Ruby and Rails versions against upstream releases.
- Specify the evidence required to confirm that the evergreen workflows are targeting the intended Ruby patch line and Rails upgrade lane.
- Document how version-baseline reviews should classify patch, minor, and prerelease opportunities without forcing immediate production adoption.
- Capture the repo surfaces that must stay aligned during the review, including `mise.toml`, `Gemfile`, `Gemfile.next`, workflow configuration, and upgrade docs.

## Capabilities

### New Capabilities
- `evergreen-version-baseline-review`: Reviews the repo's Ruby and Rails baselines against upstream releases and validates that evergreen automation still targets the right upgrade paths.

### Modified Capabilities

## Impact

- `mise.toml`
- `Gemfile`
- `Gemfile.next`
- GitHub Actions evergreen workflows
- upgrade and runtime management documentation
- issue triage and release-process review
