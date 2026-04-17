## Why

The repo can now detect some upgrade opportunities, but it still lacks a defined path for turning detected Ruby and Rails upgrades into reviewed, mergeable changes. This change is needed now so evergreen automation does not stop at detection or validation without a clear ownership, approval, and merge process.

## What Changes

- Define promotion flows for Ruby patch bumps, Ruby minor bumps, stable Rails updates, and prerelease Rails next-lane upgrades.
- Specify the approval gates, test gates, and ownership expectations for each promotion scenario.
- Document the evidence required before an evergreen-detected upgrade can move from automation output to a normal PR and merge decision.
- Clarify when upgrades remain validation-only and when they become candidates for production adoption.

## Capabilities

### New Capabilities
- `evergreen-upgrade-promotion`: Defines how Ruby and Rails upgrades move from evergreen detection into proposed, reviewed, and merged changes.

### Modified Capabilities

## Impact

- GitHub Actions evergreen workflows
- Dependabot and automation PR process
- upgrade governance and approval flow
- release-process documentation
- issue ownership and merge criteria
