# PR 812 Review Notes

## Summary of Proposed Changes
- Introduces a new `.pr-workflow.yml` configuration file with repository-wide automation settings.
- Adds large automation scripts such as `bin/cli-error-handler`, `review_pr.sh`, and supporting documentation.
- Commits additional operational data under `.project/data/` and a `priorities.json` catalog for issue triage.

## Issues Requiring Attention

### 1. Base branch misconfiguration
The proposed `.pr-workflow.yml` sets `baseBranch: main`.

```
baseBranch: main
mergeMethod: squash
pollInterval: 300
```

This repository's protected workflow is built around the `develop` branch rather than `main`, so using `main` here would send automation to the wrong branch and likely stall merges. Project workflow docs explicitly call out the protections on `develop`, indicating it is part of the primary workflow surface.【F:docs/git-workflow.md†L11-L49】 Aligning the configuration with `develop` (or making it configurable per environment) is necessary.

### 2. Committing generated GitHub metadata
The PR attempts to add `.project/data/branches.json` with an entire snapshot of remote branch metadata, e.g.:

```
[{"name":"bugfix/fix-flipper-pstore","commit":{"sha":"c4794dca69b58c8e44b471d0c667e487f7e1a23a"},"protected":false}, …]
```

and a similar `.project/data/prs.json` payload. These files will drift immediately, contain historical SHAs unrelated to the feature, and leak operational state that should be queried live instead of version-controlled. They should be dropped in favor of dynamic API calls.

### 3. Missing dependency for `shellescape`
Inside `lib/cli_error_handler.rb`, the script calls `comment_body.shellescape` when building a GitHub CLI command:

```
command = "mise exec -- gh pr comment #{pr_number} --body #{comment_body.shellescape}"
```

However, the require block at the top of the file only brings in `json`, `logger`, `open3`, and `time`, so `Shellwords` is never loaded and the monkey-patched `String#shellescape` method is undefined. Any execution path that posts a comment will raise `NoMethodError`. Adding `require 'shellwords'` (or using `Shellwords.shellescape`) fixes the bug.

## Suggested Next Steps
1. Update `.pr-workflow.yml` so the base branch matches the repository's protected `develop` workflow.
2. Remove `.project/data/*.json` (and similar generated metadata) from version control.
3. Require `shellwords` (or adjust the implementation) before calling `shellescape` in the CLI error handler.
