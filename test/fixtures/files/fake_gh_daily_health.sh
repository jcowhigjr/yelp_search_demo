#!/usr/bin/env bash
# Fake gh CLI for DailyRepoHealthFindingsTest.
# Logs every call to GH_STUB_LOG and emits fixture JSON from GH_STUB_DIR.
# Validates --jq like the real CLI: bare arguments after the expression are an
# error (this is what made daily-repo-health.yml fail before issue #3003).
printf '%s\n' "$*" >> "$GH_STUB_LOG"
if [ "${GH_STUB_FAIL:-0}" = "1" ]; then
  echo "gh: forced failure (injected)" >&2
  exit 1
fi
args=("$@")
for i in "${!args[@]}"; do
  if [ "${args[$i]}" = "--jq" ]; then
    for ((k = i + 2; k < ${#args[@]}; k++)); do
      case "${args[$k]}" in
        -*) ;;
        *) echo "unknown arguments; please quote all values that have spaces" >&2; exit 1 ;;
      esac
    done
  fi
done
case "$1" in
  pr)
    case "$*" in
      *--author*) cat "$GH_STUB_DIR/prs_dependabot.json" ;;
      *) cat "$GH_STUB_DIR/prs.json" ;;
    esac
    ;;
  run)
    case "$*" in
      *production-smoke-check.yml*) cat "$GH_STUB_DIR/smoke.json" ;;
      *) cat "$GH_STUB_DIR/ci.json" ;;
    esac
    ;;
esac
