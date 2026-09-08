# Review record - <branch or PR title>

Copy this file to `docs/reviews/YYYY-MM-DD-<short-slug>.md` and fill it in when
satisfying the Definition of Done via a local MCP or CLI review (Route B in
`docs/AGENTS.md`). Reference it from the commit with a `Review-record:` trailer.

The reviewer must not have authored the change and must start from a fresh
context. Every reported finding must have survived an explicit attempt to
disprove it; the ones that did not survive go under "Disproved".

These records are **spot-checked by hand** against the diffs they describe. The
automated check confirms the record is complete and consistent; a human confirms
it is true. Write it for that reader.

**If you are not confident, stop and say so.** Set `Escalated to human?` to
`yes - <reason>` and leave Findings and Disproved empty. That is a complete,
honest record and it passes validation. There is never a reason to invent a
review to fill this in: a fabricated record is worse than no record, because it
removes the signal that a human should look. Handing work back is a valid
outcome of doing the work.

## Provenance

| Field | Value |
|-------|-------|
| Date (UTC) | YYYY-MM-DD |
| Commit(s) reviewed | `<sha>` (and range, if more than one) |
| Reviewer | `<tool>/<model>` - e.g. `codex/gpt-5.4`, `claude/opus` |
| Invocation | the exact command or MCP tool call that produced the review |
| Requested by | who or what ran it |
| Authored the change? | yes / no - "yes" makes this a self-review, not an independent one |
| Fresh context? | yes / no - "no" if the reviewer had already seen the reasoning behind the code |
| Independent? | yes only when the two rows above are "no" and "yes" respectively |
| Escalated to human? | no - or "yes - <what you were not confident about>" if you stopped rather than guess |
| Given | diff only / full repo - prefer full repo; most real bugs live in the callers |

## Findings

Only findings that survived the disprove-it pass. One row each. Every finding
needs a disposition; "noted" is not one.

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|
| 1 | high / medium / low | what the reviewer said | fixed in `<sha>` / declined - reason / not applicable - reason |

## Disproved

Candidate findings the reviewer raised and then falsified. Listing them is what
makes the disprove-it pass auditable rather than assumed - an empty section here
on a large change usually means the pass did not really happen.

| Candidate finding | Why it does not hold |
|-------------------|----------------------|
| what was suspected | the code or test that shows it is fine |

## Not reviewed

Anything the reviewer could not see - files outside the diff, runtime behaviour,
generated assets. Say so plainly; an audit record that implies full coverage it
did not have is worse than no record.

## Verification

Commands run after the review, with their results. Evidence, not assertion.

```
<command>
<result>
```
