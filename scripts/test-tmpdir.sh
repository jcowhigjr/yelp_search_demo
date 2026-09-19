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
# dir; fall back to a short, private, repo-scoped dir only when it cannot fit.
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

# Measure BYTES, not characters. The kernel enforces sun_path in bytes, while
# ${#var} counts characters under a multibyte LC_CTYPE (en_US.UTF-8 on most dev
# machines), which under-measures any non-ASCII path.
byte_len() { LC_ALL=C printf '%s' "$1" | wc -c | tr -d '[:space:]'; }

# NOTE: every failure below is checked explicitly rather than left to `set -e`.
# bash disables errexit for the whole body of a function invoked as the left
# operand of `||`, so an unchecked `mkdir -p` in that position would fail
# silently and we would hand back a path that does not exist or is not writable.

# 1. Preferred: repo-local tmp, the existing behaviour. Its mode is left alone -
#    it is part of the checkout, not ours to tighten.
local_tmp="$PWD/tmp"
if [ "$(byte_len "$local_tmp")" -le "$budget" ] &&
  mkdir -p "$local_tmp" 2>/dev/null &&
  [ -w "$local_tmp" ]; then
  printf '%s\n' "$local_tmp"
  exit 0
fi

# Repo-scoped suffix so concurrent checkouts and worktrees never share a socket
# dir. cksum is POSIX and present everywhere; this is a collision-avoidance id,
# not a security boundary - the 0700 mode below is what keeps it private.
repo_id="$(printf '%s' "$PWD" | cksum | cut -d' ' -f1)"

# 2. Under the system temp dir (per-user already on macOS), else 3. /tmp, which
#    is short everywhere.
for base in "${TMPDIR:-/tmp}" /tmp; do
  candidate="${base%/}/ysd-test-${repo_id}"
  [ "$(byte_len "$candidate")" -le "$budget" ] || continue
  mkdir -p "$candidate" 2>/dev/null || continue
  # Must be private AND ours. If the mode cannot be enforced - a stale dir left
  # by another uid, e.g. a previous container run - skip rather than return a
  # path that is neither private nor reliably writable.
  chmod 700 "$candidate" 2>/dev/null || continue
  [ -w "$candidate" ] || continue
  printf '%s\n' "$candidate"
  exit 0
done

printf 'test-tmpdir: no candidate fits the %s-byte sun_path budget\n' \
  "$sun_path_max" >&2
exit 1
