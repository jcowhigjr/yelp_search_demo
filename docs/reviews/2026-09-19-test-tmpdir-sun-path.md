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

- **The rewritten script was not re-reviewed by an independent reviewer.** The three fixes above were authored in response to this review and verified by the author only (see Verification). A second independent pass over the rewrite would be a reasonable ask before merge.
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
