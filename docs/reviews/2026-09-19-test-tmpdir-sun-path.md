# Review record - fix(dx): keep the DRb test socket path inside sun_path

## Provenance

| Field | Value |
|-------|-------|
| Date (UTC) | 2026-09-19 |
| Commit(s) reviewed | `df61940` (range `bc81530..df61940`) |
| Reviewer | `claude/opus-5` |
| Invocation | `claude -p "<fresh-context falsification-required review of df61940>" --output-format json --allowedTools "Read,Glob,Grep,Bash(git diff:*),Bash(git log:*),Bash(git show:*),Bash(git status:*),Bash(bash:*),Bash(sh:*),Bash(printf:*),Bash(uname:*)"` |
| Requested by | jcowhigjr, via a Claude Code session working #3023 |
| Authored the change? | no |
| Fresh context? | yes |
| Independent? | yes |
| Escalated to human? | no |
| Given | full repo |

The reviewer ran 39 turns with 11 permission denials. It was given shell access
specifically so it could execute the script under test, which is how finding 1
below was demonstrated rather than merely argued.

## Findings

All three survived the disprove pass and all three are fixed. The reviewer's
findings were against `df61940`; the fixes are in the commit carrying this record.

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|
| 1 | medium | `emit_if_fits` could emit a directory that was never created or is not writable. bash disables `errexit` for the **entire body** of a function invoked as the left operand of `||`, and every call site was `emit_if_fits "..." \|\| true`. So a failing `mkdir -p` did not abort and did not fall through to the next candidate - the function kept running, printed the path, and `exit 0`d. `TMPDIR="$(scripts/test-tmpdir.sh)"` would then hold a path that may not exist. The reviewer noted this hit the fallback branch hardest, since nothing pre-creates that directory. | fixed in the commit carrying this record. Restructured so no function runs as the LHS of `\|\|`; every `mkdir`/`chmod` result is checked explicitly and a failure `continue`s to the next candidate. Reproduced the errexit behaviour first: `f() { false-cmd; echo ran; return 1; }; set -e; f \|\| true` prints `ran`. |
| 2 | low | `budget` did not reserve a byte for the NUL terminator. `sun_path_max` (104/108) is the raw buffer size; a C string needs a trailing NUL, so usable length is `sun_path_max - 1`. In the worst case the check admitted a path exactly one byte too long. | fixed: `budget=$((sun_path_max - 1 - SUFFIX_MAX))`, now 87 bytes on macOS. |
| 3 | low | The length check used `${#1}`, which counts **characters**, not bytes, under a multibyte `LC_CTYPE`. `sun_path` is enforced in bytes, so a non-ASCII path near the boundary could be under-measured and wrongly admitted. | fixed: `byte_len()` measures with `LC_ALL=C printf '%s' \| wc -c`. Confirmed the gap is real: `café` is 4 characters, 5 bytes. |

## Disproved

| Candidate finding | Why it does not hold |
|-------------------|----------------------|
| "`cksum` collisions between two `$PWD` paths could make checkouts share a socket dir." | 32-bit CRC; birthday bound needs tens of thousands of concurrent distinct repo paths. Even on a collision the socket *filename* is `druby<pid>.<n>`, so two processes sharing a directory do not clobber each other. |
| "The TOML escaping `\"$(...)\"` is wrong, or the shell does not receive a proper quoted substitution." | TOML basic-string `\"` decodes to a literal `"`, so the parsed `run` value is `TMPDIR="$(scripts/test-tmpdir.sh)" bin/rails …`. `mise.toml` sets no custom `shell`, so it runs under `sh -c`, which supports it. Confirmed by printing the parsed value with `tomllib`. |
| "The script mishandles a `$PWD` containing spaces." | Every expansion is double-quoted (`"$PWD/tmp"`, `mkdir -p "$1"`, `printf '%s\n' "$1"`), as is the TOML-level `TMPDIR="$(…)"`. A space-containing path survives intact. |
| "The script mishandles an unset `TMPDIR`." | `"${TMPDIR:-/tmp}"` defaults explicitly, and that is the only place a pre-existing `TMPDIR` is read. |
| "Something still depends on `TMPDIR` being literally `$PWD/tmp`." | Checked `lefthook.yml` (runs no tests directly), all `.github/workflows/*.yml` (every test job calls the `mise run test*` tasks, never raw `bin/rails test`), `test/` helpers (only an unrelated `mktemp -d` in `test/scripts/stacked_pr_cli_test.sh`), and `.gitignore` (its `/tmp/*` entries concern the repo-local `tmp/`, which each task still creates via its own `mkdir -p tmp`). |
| "`set -euo pipefail` plus `\|\| true` lets the script exit silently with no output on the success path." | Not on the success path: the emit branch calls `exit 0`, terminating before `\|\| true` is reached. The genuine defect was the unchecked-failure case, recorded as finding 1 rather than dismissed. |

## Not reviewed

- ~~The rewritten script was not re-reviewed by an independent reviewer.~~ **Done** - second pass (see below). ~~Post-`050dc55` not re-reviewed.~~ **Done** - third pass (see "Third review" below).
- **Linux behaviour was not executed**, only reasoned about: `sun_path_max=108` and the `uname -s` branch are untested on Linux from this macOS host. CI exercises the Linux path on this PR.
- **System/`next`-environment test tasks** use the same `TMPDIR=` rewrite but were not run locally; only `mise run test` was executed.

## Verification

```
./scripts/validate-mise-toml.sh          # taplo
mise.toml: valid

mise run test                            # deep worktree, 97-byte $PWD/tmp, no PARALLEL_WORKERS override
Running 99 tests in parallel using 3 processes
99 runs, 456 assertions, 0 failures, 0 errors, 0 skips
```

Failure paths exercised directly against the rewritten script:

```
unwritable $PWD/tmp (mode 500)        -> skipped, emitted /tmp/ysd-test-<id>
candidate blocked by a regular file   -> skipped, emitted /tmp/ysd-test-<id>
every candidate blocked               -> exit 1, "no candidate fits the 104-byte sun_path budget"
short checkout (/tmp/shortrepo)       -> /tmp/shortrepo/tmp   (preferred path still wins)
```

Before the fix the first three of those emitted a path anyway and exited 0.


---

# Second review - the rewrite

Requested because the first review's three fixes had only ever been verified by
their author. Reviewer: `claude/opus-5`, fresh context, full repo, shell access
so it could run the script adversarially. 27 turns, 9 permission denials.
Reviewed the post-fix state of `scripts/test-tmpdir.sh` on
`fix/issue-tmpdir-socket-path`, which the first reviewer never saw.

It confirmed all three original fixes are real, not papered over, and found two
further defects.

## Findings

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|
| 4 | medium | `chmod 700 "$candidate"` follows symlinks. The candidate path is fully predictable from `$PWD`. With a symlink planted there, `mkdir -p` is a silent no-op and `chmod 700` retargets onto the link's **target** - mutating an unrelated directory the invoking uid owns - after which the script returns the unvetted path as safe. The existing "stale dir owned by another uid" guard does not cover the same-uid case. | fixed in the commit carrying this update: the loop refuses a pre-existing symlink and re-checks after `mkdir` to close the swap window. Reproduced first: a link to a mode-755 dir had its target changed to 700 and the path returned. After the fix the link is skipped, the decoy stays `drwxr-xr-x`, and the script falls through to `/tmp`. |
| 5 | low | `repo_id="$(printf … \| cksum \| cut …)"` is a bare assignment, so it is **not** covered by this script's own "every failure is checked explicitly" rule. Under `set -e` a failing pipeline aborts the whole run, so a missing `cksum` would kill the script with a raw shell error instead of falling through to `/tmp`. | fixed: guarded behind `command -v cksum`, with a deterministic path-derived id as fallback and a final `default`. Verified with `cksum` removed from `PATH`: the script now returns `…/ysd-test-iew-github-prs-5c6196` instead of aborting. |

## Disproved (second review)

| Candidate | Why it does not hold |
|-----------|----------------------|
| Original finding 1 (errexit disabled inside a function on the LHS of `\|\|`) still present. | Gone. `mkdir -p … \|\| continue` and `chmod 700 … \|\| continue` invoke external commands directly; no shell function appears on the left of `\|\|` anywhere in the rewrite. |
| Original finding 2 (no NUL byte reserved) still present. | `budget=$((sun_path_max - 1 - SUFFIX_MAX))` subtracts it explicitly. |
| Original finding 3 (characters not bytes) still present. | `byte_len()` uses `LC_ALL=C printf '%s' \| wc -c`; POSIX `wc -c` is a byte count. |
| `for base in "${TMPDIR:-/tmp}" /tmp` misbehaves when both entries are identical (`TMPDIR=/tmp`). | Traced under `bash -x`: the loop `exit 0`s on the first iteration, so the duplicate is never reached. In a failure case both iterations compute the same candidate and fail identically - redundant, not incorrect. |
| `byte_len`'s subshell inside `[ ]` aborts under `set -e`. | Simulated a missing `wc`: the empty substitution makes `[` return non-zero, which the enclosing `if`/`\|\|` consumes as intended. Unlike finding 5, this call site is always in a conditional context. |
| `$PWD` deleted mid-run breaks it. | `mkdir -p` recreates the tree; the script still returns a valid writable path. Surprising, not a bug. |

## Verification (second round)

```
symlink planted at the candidate path   -> skipped; decoy stays drwxr-xr-x; falls through to /tmp
cksum removed from PATH                 -> path-derived id used; no abort
every candidate blocked by a file       -> exit 1, "no candidate fits the 104-byte sun_path budget"
short checkout                          -> $PWD/tmp still preferred
mise run test (deep worktree, parallel) -> 99 runs, 456 assertions, 0 failures
```

---

# Third review - post-050dc55

Requested by the user (plan option A) because each prior round still found real
defects. Reviewer: `codex/gpt-6-astra` via `codex exec` (Claude CLI credits were
exhausted). Fresh context, full repo, shell access, adversarial execution with
real Ruby DRb 2.2.3. Verdict was `needs-fixes`. All five survivors below are
fixed in the commit carrying this update.

## Findings

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|
| 6 | medium | Symlink recheck before `chmod` still raced: a concurrent swap of the predictable candidate path for a same-uid decoy link let `chmod 700` mutate the decoy. Stationary-symlink guard was real but incomplete. | fixed: abandoned predictable `mkdir`/`chmod` paths. Fallback now uses `mktemp -d` under umask `077` (unique private dir at creation). No pathname-based `chmod` on a reusable candidate. |
| 7 | low | Missing `wc` made length checks fail *open*: empty `byte_len` made `[ "" -gt "$budget" ]` false, so an overlong path was accepted and DRb died with sun_path overflow. | fixed: `byte_len` validates numeric output and returns nonzero on failure; `fits_budget` fails closed. Verified: missing `wc` -> exit 1, no path emitted. |
| 8 | medium | Local `$PWD/tmp` with mode `0600` passed `-w` but is not searchable; DRb could not create sockets inside it. | fixed: `is_usable_dir` requires `-d`, not a symlink, `-w`, and `-x`. Mode `0600`/`0500` fall through to mktemp fallback. |
| 9 | medium | Mise tasks used `TMPDIR="$(scripts/test-tmpdir.sh)" cmd`. A failed substitution inside an assignment does not stop `cmd`, so Rails ran with empty `TMPDIR`. | fixed: every test task is now `resolved=$(scripts/test-tmpdir.sh) && export TMPDIR="$resolved" && …`. Helper failure aborts before Rails. |
| 10 | medium | `test-smoke` / `test-next-smoke` applied TMPDIR only to `test:prepare`; the following test command inherited the long ambient TMPDIR and still overflowed sun_path. | fixed: `export TMPDIR="$resolved"` so both commands in the `&&` chain receive it. Verified both lines report the same short `ysd-test.*` path. |

## Disproved (third review)

| Candidate | Why it does not hold |
|-----------|----------------------|
| Spaces break quoting | Short and deep space-containing `$PWD` both succeed. |
| Unset TMPDIR / duplicate `/tmp` entries break fallback | Both succeed; blocked candidates exit 1 with no stdout. |
| Ordinary concurrent invocations conflict | Each gets its own `mktemp` dir (or shared local tmp when preferred). |
| Missing `mkdir`/`chmod` false success | N/A after mktemp path; missing `mktemp` exits 1 explicitly. |
| macOS `/tmp` is a symlink so fallback is impossible | Addressed: bases use `is_usable_base` (allows symlink bases like `/tmp` -> `/private/tmp`); returned candidates still must be real dirs. |

## Confirmed still fixed (prior 1-5)

| Prior | Status after third-round fixes |
|---|---|
| 1 unchecked mkdir/chmod | Still held; plus searchable-dir check and mktemp creation. |
| 2 NUL byte reserved | Unchanged; 87-byte budget on macOS. |
| 3 bytes not characters | Unchanged; fail-closed numeric `byte_len`. |
| 4 symlink chmod | Strengthened: no predictable chmod path remains. |
| 5 missing cksum abort | Path-derived id path removed with mktemp rewrite; missing `mktemp`/`wc` fail closed instead. |

## Verification (third round)

```
deep checkout                         -> /tmp/ysd-test.XXXXXX (mode 0700), socket bind OK
short checkout                        -> $PWD/tmp preferred
mode 0600 / 0500 local tmp            -> fallback mktemp; local mode untouched
missing wc                            -> exit 1, no path
helper failure in mise task           -> rc!=0, Rails never starts
test-smoke both commands              -> same exported short TMPDIR
mise run test (deep worktree, parallel) -> 99 runs, 456 assertions, 0 failures
./scripts/validate-mise-toml.sh       -> taplo OK
```

## Not reviewed / residual

- The state after *these* third-round fixes has not been independently re-reviewed.
- Linux `sun_path_max=108` still only exercised in CI, not on this macOS host.
- System / `next` tasks share the same wiring pattern but were not run end-to-end locally beyond decoded-command probes.
