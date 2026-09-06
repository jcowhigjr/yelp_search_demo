#!/usr/bin/env bash
#
# Link this repository's shared agent skills into the per-harness directories
# that each CLI or IDE agent actually reads.
#
# The canonical skills live in .agents/skills/<name>/SKILL.md. Everything this
# script creates is a symlink back to that directory, so a skill is edited in
# exactly one place and every harness sees the edit immediately.
#
# Claude Code needs no linking - .claude/skills/ is committed to the repo.
#
# Targets inside the repo (Windsurf, Cursor) are gitignored, since the symlinks
# they create carry absolute machine-specific paths.
#
# Usage:
#   scripts/install-agent-skills.sh            # link into every harness found
#   scripts/install-agent-skills.sh --dry-run  # show what would happen
#   scripts/install-agent-skills.sh --list     # show detected harnesses only

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_SRC="${REPO_ROOT}/.agents/skills"

DRY_RUN=false
LIST_ONLY=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --list)    LIST_ONLY=true ;;
    -h|--help) sed -n '2,18p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

if [[ ! -d "$SKILL_SRC" ]]; then
  echo "❌ No skills directory at ${SKILL_SRC}" >&2
  exit 1
fi

# Candidate targets: "<label>|<skills dir>|<marker that proves the harness is installed>"
# A target is only used when its marker exists, so we never create stray
# directories for tools this machine does not have.
TARGETS=(
  "Codex CLI|${HOME}/.codex/skills|${HOME}/.codex"
  "Gemini CLI|${HOME}/.gemini/skills|${HOME}/.gemini"
  "Windsurf|${REPO_ROOT}/.windsurf/skills|${REPO_ROOT}/.windsurf"
  "Warp|${HOME}/.warp/skills|${HOME}/.warp"
  "Cursor|${REPO_ROOT}/.cursor/skills|${REPO_ROOT}/.cursor"
)

link_skill() {
  local label="$1" dest_dir="$2" skill_path="$3"
  local skill_name link
  skill_name="$(basename "$skill_path")"
  link="${dest_dir}/${skill_name}"

  if [[ -L "$link" ]]; then
    if [[ "$(readlink "$link")" == "$skill_path" ]]; then
      echo "   = ${label}: ${skill_name} (already linked)"
      return
    fi
  elif [[ -e "$link" ]]; then
    echo "   ! ${label}: ${skill_name} exists and is not a symlink - skipping" >&2
    return
  fi

  if $DRY_RUN; then
    echo "   + ${label}: would link ${skill_name} -> ${skill_path}"
    return
  fi

  mkdir -p "$dest_dir"
  ln -sfn "$skill_path" "$link"
  echo "   + ${label}: linked ${skill_name}"
}

found_any=false
for target in "${TARGETS[@]}"; do
  IFS='|' read -r label dest_dir marker <<<"$target"
  [[ -d "$marker" ]] || continue
  found_any=true

  echo "🔗 ${label}  ->  ${dest_dir}"
  if $LIST_ONLY; then
    continue
  fi

  for skill_path in "$SKILL_SRC"/*/; do
    [[ -f "${skill_path}SKILL.md" ]] || continue
    link_skill "$label" "$dest_dir" "${skill_path%/}"
  done
done

if ! $found_any; then
  echo "ℹ️  No supported agent harnesses detected on this machine."
  echo "   Skills remain available in-repo at .agents/skills/ and .claude/skills/."
  exit 0
fi

echo
echo "✅ Done. Canonical skills stay in .agents/skills/ - edit them there."
