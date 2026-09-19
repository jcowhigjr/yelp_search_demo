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
budget=$((sun_path_max - SUFFIX_MAX))

emit_if_fits() {
  [ "${#1}" -le "$budget" ] || return 1
  mkdir -p "$1"
  chmod 700 "$1" 2>/dev/null || true
  printf '%s\n' "$1"
  exit 0
}

# 1. Preferred: repo-local tmp, the existing behaviour.
emit_if_fits "$PWD/tmp" || true

# Repo-scoped suffix so concurrent checkouts and worktrees never share a socket
# dir. cksum is POSIX and present everywhere; this is a collision-avoidance id,
# not a security boundary - the 0700 mode above is what keeps it private.
repo_id="$(printf '%s' "$PWD" | cksum | cut -d' ' -f1)"

# 2. Under the system temp dir, which on macOS is already per-user.
system_tmp="${TMPDIR:-/tmp}"
emit_if_fits "${system_tmp%/}/ysd-test-${repo_id}" || true

# 3. Last resort: /tmp is short everywhere. 0700 covers the shared-dir case.
emit_if_fits "/tmp/ysd-test-${repo_id}" || true

printf 'test-tmpdir: no candidate fits the %s-byte sun_path budget\n' \
  "$sun_path_max" >&2
exit 1
