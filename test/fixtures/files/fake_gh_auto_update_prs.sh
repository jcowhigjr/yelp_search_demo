#!/usr/bin/env bash
# Fake gh CLI for AutoUpdatePrsTest.
# Logs every call to GH_STUB_LOG. Fixture files in GH_STUB_DIR:
#   prs.json  - emitted by `gh pr list`
#   seq-<N>   - mergeStateStatus values returned in order by `gh pr view N`
#   head-<N>  - current head SHA for PR N; `update-branch` appends "-updated"
printf '%s\n' "$*" >> "$GH_STUB_LOG"
sub="$1"; shift || true
case "$sub" in
  pr)
    action="$1"; shift || true
    case "$action" in
      list)
        cat "$GH_STUB_PRS"
        ;;
      view)
        pr="$1"; shift || true
        head=$(cat "$GH_STUB_DIR/head-$pr" 2>/dev/null || echo unknown)
        if [[ "$*" == *mergeStateStatus* ]]; then
          idx_file="$GH_STUB_DIR/idx-$pr"
          idx=$(cat "$idx_file" 2>/dev/null || echo 0)
          state=$(sed -n "$((idx + 1))p" "$GH_STUB_DIR/seq-$pr")
          [ -z "$state" ] && state=$(tail -n 1 "$GH_STUB_DIR/seq-$pr")
          echo $((idx + 1)) > "$idx_file"
          printf '{"mergeStateStatus":"%s","headRefOid":"%s"}\n' "$state" "$head"
        else
          printf '{"headRefOid":"%s"}\n' "$head"
        fi
        ;;
      merge)
        exit 0
        ;;
    esac
    ;;
  api)
    for a in "$@"; do
      case "$a" in
        repos/*/pulls/*/update-branch)
          pr=$(echo "$a" | sed -E 's|.*/pulls/([0-9]+)/.*|\1|')
          echo "$(cat "$GH_STUB_DIR/head-$pr")-updated" > "$GH_STUB_DIR/head-$pr"
          ;;
      esac
    done
    ;;
  workflow)
    exit 0
    ;;
esac
