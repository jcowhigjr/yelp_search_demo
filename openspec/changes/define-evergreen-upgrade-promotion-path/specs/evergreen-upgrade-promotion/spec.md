## ADDED Requirements

### Requirement: Promotion path SHALL classify upgrade types
The repo SHALL define separate promotion paths for Ruby patch bumps, Ruby minor bumps, stable Rails updates, and prerelease Rails next-lane upgrades.

#### Scenario: Routing a detected upgrade
- **WHEN** evergreen automation detects or validates an upgrade opportunity
- **THEN** the repo classifies the opportunity into one of the defined upgrade types before deciding the next action

### Requirement: Promotion path SHALL require evidence before proposal
The repo SHALL define the minimum verification evidence required before automation output becomes a normal PR or merge candidate.

#### Scenario: Ruby patch bump candidate
- **WHEN** automation proposes a Ruby patch bump within the current minor line
- **THEN** the promotion path requires synchronized runtime declarations and passing smoke verification before the PR is treated as reviewable

#### Scenario: Stable Rails update candidate
- **WHEN** automation or Dependabot proposes a stable Rails update
- **THEN** the promotion path requires CI evidence appropriate to the affected Rails scope before merge consideration

### Requirement: Higher-risk upgrades SHALL require explicit approval
The repo SHALL require explicit human approval for higher-risk upgrade classes before they move from validation into mergeable work.

#### Scenario: Ruby minor upgrade candidate
- **WHEN** the detected upgrade changes the Ruby minor line
- **THEN** the promotion path requires explicit approval and compatibility review before the repo opens or advances a merge candidate

#### Scenario: Prerelease Rails next-lane result
- **WHEN** the next-lane workflow validates a prerelease Rails target
- **THEN** the result remains validation-only unless a maintainer explicitly promotes it into an adoption plan

### Requirement: Promotion path SHALL define ownership handoff
The repo SHALL define who closes the loop when automation detects an upgrade but cannot safely merge it on its own.

#### Scenario: Automation stops at validation
- **WHEN** a workflow succeeds in detection or validation but no merge-safe action exists
- **THEN** the promotion path identifies the maintainer action required to review, propose, or defer the upgrade
