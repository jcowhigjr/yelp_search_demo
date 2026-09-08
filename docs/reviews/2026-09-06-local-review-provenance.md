# Review record - docs/local-review-provenance

Covers the change that adds Route B (locally-requested MCP/CLI review) to the
Definition of Done, plus the template and validator that make it auditable.

## Provenance

| Field | Value |
|-------|-------|
| Date (UTC) | 2026-09-08 |
| Commit(s) reviewed | `docs/local-review-provenance` vs `develop` @ `8a04192` |
| Reviewer | `claude/opus-5` running as a `feature-dev:code-reviewer` subagent |
| Invocation | fresh subagent given the branch, the base commit, and the four files under review; instructed to disprove each finding before reporting it |
| Requested by | jcowhigjr |
| Authored the change? | no |
| Fresh context? | yes - the reviewer never saw the reasoning that produced the change, only the result |
| Independent? | yes |
| Escalated to human? | no |
| Given | full repo |

Independence here is architectural, not vendor-based: the reviewer shares a model
family with the author but has a separate context and an adversarial role. That
is the standard this change adopts, and the reasoning is in `docs/AGENTS.md`.

Note the reviewer had no shell tool and reasoned about the bash by hand. Its two
highest-severity findings were then reproduced empirically against a scratch
repository before being accepted; both were real.

## Findings

Only findings that survived the disprove-it pass.

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|
| 1 | high | `section_of` required a byte-exact heading match, so renaming `## Provenance` to `## Provenance (self-review)` emptied the section and disabled every placeholder check inside it. Reproduced: a record with `<sha>`, `<tool>/<model>` and `YYYY-MM-DD` in every cell passed with ✅ | fixed - heading match is now a case-insensitive prefix, and the validator was rewritten in Python |
| 2 | high | The placeholder denylist did not cover the `Authored the change?`, `Fresh context?`, `Given`, `Invocation` or `Requested by` rows added hours earlier, so leaving them as boilerplate and asserting `Independent? yes` passed. Reproduced | fixed at the class level - placeholder values are now read from `TEMPLATE.md` at runtime, so a new template row is checked the moment it is added |
| 3 | high | Nothing cross-checked an asserted `Independent? yes` against the rows that define independence | fixed - a record claiming independence while recording that the reviewer authored the change, or lacked fresh context, is now rejected |
| 4 | medium | The `## Disproved` section, which is what makes the disprove-it pass auditable, was never validated. A verbatim template row or an empty section passed | fixed - both `Findings` and `Disproved` must contain at least one row that differs from the template; `Disproved` may instead say "none" explicitly |
| 5 | medium | A commit with no `Review-record:` trailer is skipped entirely, so the cheapest bypass is to omit the trailer. Route A is likewise unverified by any tooling | accepted, documented - inherent to a trailer-based scheme. Recorded in "Known limits" below rather than papered over |
| 6 | medium | Route B is structurally more gameable than Route A, because its audit trail is a file the authoring agent writes itself rather than an external system of record | accepted, documented - see "Known limits" |
| 7 | medium | `.agents/skills/multi-model-review/SKILL.md` offers an in-session subagent as a reviewer, which may share context with the author and so is not reliably "fresh" | accepted, not fixed here - that skill is outside this change; noted for follow-up |
| 8 | high | Finding 5's "omitting the trailer skips the check" was accepted as inherent. It is not: the checker is plain Python with no model call, so it can run in CI where the author cannot skip it | fixed - `.github/workflows/review-provenance.yml` runs it on every PR with `--require-record`. No API cost |
| 9 | medium | A `sha_consistency` check that required every named commit to be inside the change flagged this record for citing its own base commit. Fourth prose-matching false positive in this branch's history | fixed by narrowing, not by exception - the check now only rejects a sha that resolves to nothing, which is provable. Membership requires guessing which mentions are claims |
| 10 | high | The mechanism had no vocabulary for "I was not confident, a human should look". `Independent? no` read as a shortfall, so the cheapest way to look compliant was to overstate a review. Raised by the repo owner | fixed - `Escalated to human?` is a first-class passing outcome requiring only a reason. Findings and Disproved may then be empty |

## Disproved

Candidates the reviewer raised and then falsified.

| Candidate finding | Why it does not hold |
|-------------------|----------------------|
| `errors=$((errors + 1))` aborts under `set -e` when the value is 0 | Assignment form returns 0 regardless of the arithmetic value; only the bare `((...))` command form returns 1, and both uses of that form are `if` conditions where `set -e` does not apply |
| Regex metacharacters in the placeholder tokens break `grep -E` | None of `<`, `>`, `/`, or `-` are special in extended regex in those positions |
| `local a="$1" b="$2"` is invalid bash | Multiple `local` assignments on one line are valid |
| Merge commits break `git show <sha>:<path>` or trailer extraction | Both work identically on merge commits, and the repo requires linear history on `develop` |
| A failing `git show` inside process substitution aborts the script | Bash does not propagate a process substitution's status to the enclosing compound command; the loop body simply would not run |
| The whitespace trim mangles record paths containing internal spaces | The parameter-expansion idiom strips only leading and trailing whitespace; verified against `docs/reviews/a b.md` |
| The template-detection comparison is pattern-matched | The right-hand side is quoted, so `[[ x == "y" ]]` compares literally |

## Known limits

These are real and unfixed. They are recorded so the mechanism is not mistaken
for more than it is.

- ~~**Omitting the trailer skips the check entirely.**~~ Fixed. The checker now
  runs in CI with `--require-record`, so a change with no record fails there
  regardless of what happens on the author's machine. This costs no API spend -
  the checker calls no model. What remains outside CI is the *review* itself,
  which is a deliberate cost decision, not an oversight.
- **The record is self-written.** A determined author can produce a plausible
  record for a review that never happened. The check raises the cost of faking
  it; it does not make faking it impossible.
- **Review quality is unverified by tooling.** The validator checks structure
  only; a well-written record of a shallow review passes like a thorough one.
  This is covered by manual spot-checks of records against their diffs, which is
  the intended backstop rather than a gap to automate away.

## Not reviewed

- The **quality** of any review this mechanism records.
- Whether Route B weakens standards in practice. The honest answer is that it
  can; the mitigation is that weak or absent reviews become visible.
- `docs/AGENTS.md` prose beyond the section edited.

## Verification

```
python3 -m unittest discover -s .agents/scripts -p 'test_*.py'
Ran 30 tests in 0.002s - OK

verify_review_provenance.py <range> --require-record   # record present -> exit 0
verify_review_provenance.py <no-record range> --require-record  # -> exit 1
verify_review_provenance.py <no-record range>          # pre-push -> exit 0
```

The two high-severity findings were reproduced against a scratch repository
before the fix and confirmed rejected after it. Cases covered by the test suite:
renamed section heading, a template row added but left unedited, blank value,
missing required row, `Independent? yes` contradicted by either supporting row,
missing `Disproved` section, template example row alone in `Findings` or
`Disproved`, and an explicit "none" in `Disproved`.
