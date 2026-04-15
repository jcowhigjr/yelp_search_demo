## ADDED Requirements

### Requirement: Review declared Ruby and Rails baselines
The repo SHALL provide a repeatable review process that compares declared Ruby and Rails baselines against current upstream releases and records whether the repo is behind, aligned, or intentionally pinned.

#### Scenario: Compare current declarations with upstream releases
- **WHEN** a maintainer performs an evergreen baseline review
- **THEN** the review records the repo-declared Ruby version, the repo-declared Rails stable or prerelease target, and the latest relevant upstream Ruby and Rails releases

#### Scenario: Preserve intentional pinning decisions
- **WHEN** the repo remains on an older Ruby patch, Ruby minor, or Rails target by policy
- **THEN** the review records that the difference is intentional and names the policy or compatibility reason

### Requirement: Validate evergreen targeting surfaces together
The repo SHALL review manifests, automation configuration, and upgrade documentation together so evergreen targeting drift is detected in one pass.

#### Scenario: Cross-check all targeting surfaces
- **WHEN** a baseline review is completed
- **THEN** it verifies `mise.toml`, `Gemfile`, `Gemfile.next`, evergreen workflows, and upgrade documentation for consistency with the intended Ruby and Rails upgrade tracks

### Requirement: Separate baseline review from upgrade promotion
The repo SHALL treat baseline review output as evidence for future upgrade decisions rather than as implicit approval to adopt a new Ruby or Rails version.

#### Scenario: Review finds a newer release
- **WHEN** the review identifies a newer Ruby patch, Ruby minor, or Rails release
- **THEN** the output classifies the opportunity without requiring an immediate production version change
