#!/usr/bin/env bash
#
# Echo a TMPDIR that is safe for Rails parallel testing, and create it.
#
# Why this exists
# ---------------
# Rails' parallel test runner (ActiveSupport::Testing::Parallelization) starts a
# DRb server on a Unix domain socket. drb names it "<TMPDIR>/druby<pid>.<n>"
# (drb/unix.rb, temp_server). Unix socket paths are capped by sockaddr_un's
# sun_path field: 104 bytes on macOS/BSD, 108 on Linux.
#
# This repo pins TMPDIR to "$PWD/tmp" so test artifacts stay local and to avoid
# DRb permission errors on a shared system temp dir. In a normal checkout that
# is short and fine. In a deep one - a git worktree under .claude/worktrees/, a
# CI cache path - "$PWD/tmp" plus drb's suffix overflows sun_path and every run
# dies before a single test executes:
#
#   too long unix socket path (110bytes given but 104bytes max) (ArgumentError)
#
# That failure looks like a broken test suite but is purely a path-length
# problem, so it costs whoever hits it a debugging detour. Prefer the local tmp
# dir; fall back to a short, private dir only when it cannot fit.
set -euo pipefail

# Worst case drb suffix: "/druby" (6) + pid (up to 7 digits) + "." (1) + n (2).
readonly SUFFIX_MAX=16

case "$(uname -s)" in
  Darwin | *BSD*) sun_path_max=104 ;;
  *) sun_path_max=108 ;;
esac

# sun_path is a fixed buffer holding a C string, so one byte of it is the NUL
# terminator and the usable path length is sun_path_max - 1.
budget=$((sun_path_max - 1 - SUFFIX_MAX))

# Measure BYTES, not characters. Fail closed: missing wc / non-numeric output
# must not be treated as "fits" by a failed `[ "" -le N ]` comparison.
byte_len() {
  local n
  n=$(LC_ALL=C printf '%s' "$1" | wc -c 2>/dev/null | tr -d '[:space:]') || return 1
  case "$n" in
    '' | *[!0-9]*) return 1 ;;
  esac
  printf '%s\n' "$n"
}

fits_budget() {
  local n
  n=$(byte_len "$1") || return 1
  [ "$n" -le "$budget" ]
}

# DRb needs to create entries inside TMPDIR: directory + write + search (x).
# Bases may themselves be symlinks (macOS /tmp -> /private/tmp); that is fine.
# Candidates we return must be real directories we created or own — never a link.
is_usable_base() {
  [ -d "$1" ] && [ -w "$1" ] && [ -x "$1" ]
}

is_usable_dir() {
  [ -d "$1" ] && [ ! -L "$1" ] && [ -w "$1" ] && [ -x "$1" ]
}

# NOTE: every failure below is checked explicitly rather than left to `set -e`.
# bash disables errexit for the whole body of a function invoked as the left
# operand of `||`, so an unchecked mkdir in that position would fail silently.

# 1. Preferred: repo-local tmp, the existing behaviour. Its mode is left alone -
#    it is part of the checkout, not ours to tighten. We still require it to be
#    a real, writable, searchable directory so DRb can create sockets in it.
local_tmp="$PWD/tmp"
if fits_budget "$local_tmp" &&
  mkdir -p "$local_tmp" 2>/dev/null &&
  is_usable_dir "$local_tmp"; then
  printf '%s\n' "$local_tmp"
  exit 0
fi

if ! command -v mktemp >/dev/null 2>&1; then
  printf 'test-tmpdir: mktemp is required for fallback TMPDIR creation\n' >&2
  exit 1
fi

# 2. Under the system temp dir (per-user already on macOS), else 3. /tmp.
#    Create with mktemp -d so the path is unique and private at creation time
#    (umask 077 -> mode 0700). Do NOT mkdir/chmod a path predictable from $PWD:
#    that races with symlink swaps and can chmod an unrelated same-uid decoy.
for base in "${TMPDIR:-/tmp}" /tmp; do
  base="${base%/}"
  is_usable_base "$base" || continue

  old_umask=$(umask)
  umask 077
  candidate=$(mktemp -d "${base}/ysd-test.XXXXXX" 2>/dev/null) || {
    umask "$old_umask"
    continue
  }
  umask "$old_umask"

  if ! fits_budget "$candidate"; then
    rmdir "$candidate" 2>/dev/null || true
    continue
  fi
  if ! is_usable_dir "$candidate"; then
    rmdir "$candidate" 2>/dev/null || true
    continue
  fi

  printf '%s\n' "$candidate"
  exit 0
done

printf 'test-tmpdir: no candidate fits the %s-byte sun_path budget\n' \
  "$sun_path_max" >&2
exit 1
