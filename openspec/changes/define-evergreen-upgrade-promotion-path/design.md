## Context

The evergreen workflows can detect or prepare upgrade opportunities, but the repo still lacks a formal process for deciding when those opportunities become normal PRs and merge candidates. Without that process, automation can stop at validation and leave ownership unclear, especially across different upgrade classes such as Ruby patch bumps, Ruby minor jumps, stable Rails updates, and prerelease next-lane work.

## Goals / Non-Goals

**Goals:**
- Define distinct promotion flows for the main Ruby and Rails upgrade categories.
- Clarify the evidence, approvals, and tests required before each upgrade type is proposed or merged.
- Assign clear ownership boundaries between automation, reviewers, and maintainers.
- Preserve the repo's conservative production posture while still making automation useful.

**Non-Goals:**
- Implementing new workflow logic in this design alone.
- Auto-merging Ruby minor or Rails prerelease upgrades.
- Changing branch protection or CI policy outside the evergreen promotion scope.

## Decisions

### Model promotion by upgrade class
Promotion rules will be defined separately for Ruby patch, Ruby minor, stable Rails, and prerelease Rails next-lane updates. Each class has different compatibility risk and should not share one generic merge rule.

Alternative considered: one common promotion path for all upgrades. Rejected because it would either overconstrain patch updates or underconstrain higher-risk upgrades.

### Require evidence before ownership handoff
Automation output must be accompanied by explicit evidence, such as successful smoke runs, workflow results, or documented compatibility notes, before a human owner is asked to review or merge.

Alternative considered: allow maintainers to infer readiness from bot PRs alone. Rejected because the post-release validation already showed that workflow existence and actual execution can diverge.

### Keep prerelease Rails work validation-only by default
The next-lane Rails track will remain validation-oriented until a maintainer explicitly chooses to promote it toward production adoption.

Alternative considered: auto-promote next-lane prerelease compatibility changes once CI is green. Rejected because prerelease adoption is a policy decision, not just a CI result.

## Risks / Trade-offs

- [The process becomes too heavy for low-risk patch bumps] -> Mitigation: keep Ruby patch and stable Rails patch flows lightweight, with bounded smoke-test requirements.
- [Owners may assume automation has already made the merge decision] -> Mitigation: require explicit ownership and approval handoff in the documented path.
- [Promotion paths drift from actual workflow behavior] -> Mitigation: require the path to reference the real evergreen jobs and verification outputs.

## Migration Plan

1. Define promotion requirements and tasks in OpenSpec.
2. Align GitHub issues and docs with the promotion scenarios.
3. Implement any needed workflow or documentation changes in a later follow-up PR.
4. Use the resulting process as the gate for future evergreen-detected upgrades.

## Open Questions

- Which maintainer role owns Ruby minor upgrade decisions?
- Should stable Rails minor updates require broader review than stable patch updates in this repo?
