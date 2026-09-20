# Review record - repair bin/dev Tailwind watcher and unify compiler (#3017, #3018)

## Provenance

| Field | Value |
|-------|-------|
| Date (UTC) | 2026-09-18 |
| Commit(s) reviewed | working-tree diff on `bugfix/issue-3017-tailwind-watch` (Procfile.dev, package.json, bun.lockb, Makefile, WARP.md, new `test/integration/dev_workflow_configuration_test.rb`) |
| Reviewer | devin subagent (subagent_explore) / SWE-2 |
| Invocation | `run_subagent` with the changed-file list, issue context, and instructions to disprove each candidate finding before reporting it |
| Requested by | devin (authoring agent), per Route B in docs/AGENTS.md |
| Authored the change? | no |
| Fresh context? | yes - the reviewer saw only the repository state and the changed-file list, not the authoring session's reasoning |
| Independent? | yes |
| Escalated to human? | no |
| Given | full repo - reviewer read the changed files plus bin/dev, bin/setup, lefthook.yml, Makefile, WARP.md, Dockerfile, gem internals (tailwindcss-rails 4.6.0, tailwindcss-ruby 4.3.1, foreman 0.90.0), and all bun/tailwind consumers |

## Findings

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|
| 1 | low | `make tailwind_enforce_config` greps `css: bin/rails tailwindcss:watch`, which cannot match the new quoted line; the target was already dead on two other stale checks (`config/tailwind.config.js`, backwards `@import` check, wrong quote style on stylesheet_link_tag) | fixed - target updated to validate the actual v4 setup; `mise exec -- make tailwind_enforce_config` now passes |
| 2 | low | Dev watcher now emits minified CSS (gem's compile_command appends `--minify`); old bun path was unminified | accepted - byte-identical output to CI's `tailwindcss:build` is the point of #3018; `tailwindcss:watch[debug,always]` remains available for DevTools work |
| 3 | low | css process now boots the full Rails env (`:environment` dep) | accepted - slower start, but web was already broken in that scenario; verified working |
| 4 | low | WARP.md:104,165 still described a `yarn tailwindcss` watcher | fixed in this change |
| 5 | low | Test only guards the literal `tailwindcss` key; `@tailwindcss/*` packages would slip through | fixed - assertion now rejects any dep key containing `tailwind`, and asserts the `css:` procfile entry exists |
| 6 | info | `bun.lockb` consistency couldn't be proven by grep | resolved - `bun install --frozen-lockfile` reports 172 installs, no changes |

## Disproved

| Candidate finding | Why it does not hold |
|-------------------|----------------------|
| Foreman `#` comments unsupported | foreman 0.90.0 `procfile.rb` parses only `name: command` lines; comments ignored |
| `"task[arg]"` quoting/glob risk | foreman spawns via `sh -c`; quotes stripped, arg arrives literally |
| `watch[always]` semantics wrong | build.rake → commands.rb appends `-w always`; upstream-documented fix for closed stdin |
| Watcher orphaned on foreman shutdown | `ProcessRunner.spawn_and_wait` traps INT/TERM and forwards to the child |
| watch vs CI build divergence | `watch_command` = `compile_command` + `-w [always]`; identical flags - #3018 resolved structurally |
| `assets:clobber` removal hazard | The clobber *was* the bug (wiped builds the dead watcher never rewrote); watcher builds on start, builds gitignored |
| `bin/rails` needs `mise exec` | `web:` line already uses bare `bin/rails`; no new requirement |
| npm dep removal breaks consumers | no other `bun x`/`npx`/`yarn tailwind` anywhere; CI never runs `bun install`; no `prettier-plugin-tailwindcss` |

## Not reviewed

Stray `fc9cba94/` directory (copied lefthook.yml + workflow; untracked artifact, unrelated). Pre-existing damage flagged for a separate hygiene PR: unresolved merge-conflict markers in `Dockerfile` (lines 1-8, 38-44) and `WARP.md` (147-155).

## Verification

```
bin/dev (foreman):
  web.1 + css.1 both alive >60s (previously css exited in ~3s and foreman killed web)
  probe edit to app/assets/tailwind/application.css -> "Done in Nms" rebuild lines
  curl localhost:3000 -> 200 styled page

bin/rails test test/integration/dev_workflow_configuration_test.rb
2 runs, 11 assertions, 0 failures

bun install --frozen-lockfile --ignore-scripts
172 installs checked, no changes

mise exec -- make tailwind_enforce_config
SUCCESS: Tailwind CSS configuration validated

rubocop: clean on touched files
```
