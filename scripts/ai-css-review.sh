#!/usr/bin/env bash
# Helper for Issue #981: focused CSS/ERB cross-model review
#
# Collects diffs from CSS/Tailwind/ERB surfaces and prints a ready-to-paste
# Claude CLI prompt for UI/styling issues.

set -euo pipefail

ISSUE_REFERENCE=${1:-"<ISSUE_URL_OR_NUMBER>"}

current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "(unknown branch)")

# Prefer staged diffs for what is actually going to ship.
if git diff --cached --quiet -- 'app/assets/stylesheets' 'app/assets/tailwind' 'app/assets/builds' 'app/views'; then
  CHANGED_FILES=$(git diff --name-only -- 'app/assets/stylesheets' 'app/assets/tailwind' 'app/assets/builds' 'app/views' || true)
  DIFF_OUTPUT=$(git diff --unified=5 -- 'app/assets/stylesheets' 'app/assets/tailwind' 'app/assets/builds' 'app/views' || true)
  DIFF_SOURCE="working tree (CSS/ERB)"
else
  CHANGED_FILES=$(git diff --cached --name-only -- 'app/assets/stylesheets' 'app/assets/tailwind' 'app/assets/builds' 'app/views' || true)
  DIFF_OUTPUT=$(git diff --cached --unified=5 -- 'app/assets/stylesheets' 'app/assets/tailwind' 'app/assets/builds' 'app/views' || true)
  DIFF_SOURCE="staged changes (CSS/ERB)"
fi

# Bail out early if there are no relevant diffs.
if [ -z "${DIFF_OUTPUT}" ]; then
  echo "No CSS/ERB changes detected in app/assets/stylesheets, app/assets/tailwind, app/assets/builds, or app/views."
  echo "Stage or modify relevant files before running scripts/ai-css-review.sh."
  exit 1
fi

cat <<'INTRO'
# Copy/paste the section below into claude-cli (or your review agent)
# Example:
#   claude --model opus --message "$(scripts/ai-css-review.sh ISSUE)"
INTRO

cat <<PROMPT
## CSS/Tailwind/ERB cross-model review request (UI styling)

- **Issue / ticket**: ${ISSUE_REFERENCE}
- **Branch**: ${current_branch}
- **Diff source**: ${DIFF_SOURCE}

### 1. Symptom & expected behavior
- Symptom: <describe the current visual bug (e.g., dark-mode cards still white, layout broken, etc.)>
- Expected: <describe how the UI should look/behave>

### 2. Relevant context
- Frameworks involved: Rails views (ERB), Tailwind CSS v4, Materialize CSS (from CDN), Hotwire/Turbo.
- Risk area: CSS specificity, asset pipeline order, dark-mode behavior, or framework interaction.

### 3. Empirical check
- How I reproduced the issue (URL + steps): <fill in>
- What I saw after this change: <actual behavior/screenshot description>

### 4. Questions for reviewer
1. Do these CSS/Tailwind/ERB changes correctly resolve the visual bug without breaking other states (hover, dark mode, responsive breakpoints)?
2. Are there hidden specificity, asset-pipeline, or caching issues I should account for?
3. Is there a simpler or more robust pattern to apply here (e.g., fewer overrides, better use of variables)?

### 5. Relevant CSS/ERB diffs (truncated to ±5 lines)

Files touched:
${CHANGED_FILES:-"(none detected)"}

git diff output:
```diff
${DIFF_OUTPUT}
```
PROMPT

cat <<'HINTS'
---
## Prompt hints for UI/styling issues
- Include any screenshots (or textual descriptions) from dark/light mode.
- Mention specific selectors/classes if they seem problematic (e.g., `.card`, `.coffeeshop-card`, `dark:` utilities).
- If production behaves differently from local, note the environment differences (asset compilation, CDN, caching).
HINTS
