#!/usr/bin/env bash
set -euo pipefail

ISSUE_REFERENCE=${1:-"<ISSUE_URL_OR_NUMBER>"}
SURFACE=${2:-"ui"}

current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "(unknown branch)")

# Validate surface to catch typos early
case "$SURFACE" in
  ui|api|job)
    ;;
  *)
    echo "Unknown surface '$SURFACE'. Expected one of: ui | api | job." >&2
    exit 1
    ;;
esac

# Prefer staged diffs so prompts match what will ship. Fallback to working tree when nothing is staged.
if git diff --cached --quiet; then
  CHANGED_FILES=$(git diff --name-only || true)
  DIFF_OUTPUT=$(git diff --unified=5 || true)
  DIFF_SOURCE="working tree"
else
  CHANGED_FILES=$(git diff --cached --name-only || true)
  DIFF_OUTPUT=$(git diff --cached --unified=5 || true)
  DIFF_SOURCE="staged changes"
fi

# If there are no changes at all, abort with a clear message.
if [ -z "${DIFF_OUTPUT}" ]; then
  echo "No changes detected (staged or working tree)."
  echo "Stage or modify files before running scripts/generate-cross-model-prompt.sh."
  exit 1
fi

cat <<'INTRO'
# Copy/paste the section below into claude-cli (or your review agent)
# Example:
#   claude --model opus --message "$(scripts/generate-cross-model-prompt.sh ISSUE surface)"
INTRO

cat <<PROMPT
## Cross-model escalation request (surface: ${SURFACE})

- **Issue / ticket**: ${ISSUE_REFERENCE}
- **Branch**: ${current_branch}
- **Diff source**: ${DIFF_SOURCE}

### 1. Symptom & expected behavior
- Symptom: <summarize the bug users still see>
- Expected: <describe correct behavior>

### 2. What changed in this attempt
- Key commands/test suites that passed: <list>
- Files touched: ${CHANGED_FILES:-"(none detected)"}

### 3. Empirical check results
- Reproduction steps (UI/API/job): <detail>
- Observation after this fix: <what actually happened>
- Confidence level: <high/medium/low>

### 4. Questions for reviewer
1. Which layer might still be causing the issue?
2. What should we instrument or log next?
3. Are there simpler consolidation steps we missed?

### 5. Relevant diffs (truncated to ±5 lines)

git diff --unified=5 output:
```
${DIFF_OUTPUT:-"(no diff detected; stage or modify files before running the script)"}
```
PROMPT

cat <<'TEMPLATES'
---
## Prompt hints by surface
- **ui**: Include DOM/CSS selectors, screenshots, Tailwind + Materialize conflicts, Turbo/Turbo Frame context.
- **api**: Include request payloads, headers, and actual vs expected HTTP responses.
- **job**: Include ActiveJob name, enqueued arguments, log excerpts, and downstream side-effects.

Need richer context? Add small logs or screenshots before sending the prompt.
TEMPLATES
