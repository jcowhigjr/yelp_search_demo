#!/usr/bin/env python3
"""Tests for the review-provenance validator.

Every case here corresponds to a way the previous bash implementation could be
made to wrongly pass or wrongly fail. Run with:
    python3 -m unittest discover -s .agents/scripts -p 'test_*.py'
"""

import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from verify_review_provenance import check_record, section, table_rows  # noqa: E402

TEMPLATE = """# Review record

## Provenance

| Field | Value |
|-------|-------|
| Date (UTC) | YYYY-MM-DD |
| Commit(s) reviewed | `<sha>` |
| Reviewer | `<tool>/<model>` |
| Invocation | the exact command or MCP tool call that produced the review |
| Requested by | who or what ran it |
| Authored the change? | yes / no - "yes" makes this a self-review |
| Fresh context? | yes / no - "no" if the reviewer had seen the reasoning |
| Independent? | yes only when the two rows above are "no" and "yes" |
| Escalated to human? | no - or "yes - <reason>" if you stopped rather than guess |
| Given | diff only / full repo |

## Findings

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|
| 1 | high / medium / low | what the reviewer said | fixed in `<sha>` |

## Disproved

| Candidate finding | Why it does not hold |
|-------------------|----------------------|
| what was suspected | the code or test that shows it is fine |
"""

VALID = """# Review record

## Provenance

| Field | Value |
|-------|-------|
| Date (UTC) | 2026-09-08 |
| Commit(s) reviewed | `abc1234` |
| Reviewer | `codex/gpt-5.4` |
| Invocation | `codex exec --sandbox read-only` |
| Requested by | jcowhigjr |
| Authored the change? | no |
| Fresh context? | yes |
| Independent? | yes |
| Escalated to human? | no |
| Given | full repo |

## Findings

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|
| 1 | high | off-by-one in the cursor | fixed in `abc1234` |

## Disproved

| Candidate finding | Why it does not hold |
|-------------------|----------------------|
| suspected N+1 in the loop | the association is preloaded in the scope |
"""


def problems(content, template=TEMPLATE):
    return check_record("abc1234", "docs/reviews/r.md", content, template)


class ValidRecordPasses(unittest.TestCase):
    def test_fully_filled_record_has_no_problems(self):
        self.assertEqual(problems(VALID), [])

    def test_non_independent_record_is_still_structurally_valid(self):
        content = VALID.replace(
            "| Authored the change? | no |", "| Authored the change? | yes |"
        ).replace("| Independent? | yes |", "| Independent? | no |")
        self.assertEqual(problems(content), [])

    def test_disproved_may_say_none_explicitly(self):
        content = VALID.replace(
            "| suspected N+1 in the loop | the association is preloaded in the scope |",
            "None - no candidate findings were raised.",
        )
        self.assertEqual(problems(content), [])


class UnfilledTemplateIsRejected(unittest.TestCase):
    def test_template_copied_verbatim_is_rejected(self):
        self.assertTrue(problems(TEMPLATE))

    def test_renamed_provenance_heading_does_not_disable_the_check(self):
        # Regression: an exact heading match meant `## Provenance (self-review)`
        # silently emptied the section and skipped every check inside it.
        content = TEMPLATE.replace("## Provenance", "## Provenance (self-review)")
        found = problems(content)
        self.assertTrue(any("placeholder" in p for p in found), found)

    def test_unedited_row_added_to_the_template_is_still_caught(self):
        # Regression: placeholders were a hardcoded denylist, so every new
        # template row was unchecked until someone remembered to update it.
        content = VALID.replace(
            "| Fresh context? | yes |",
            '| Fresh context? | yes / no - "no" if the reviewer had seen the reasoning |',
        )
        found = problems(content)
        self.assertTrue(any("Fresh context?" in p for p in found), found)

    def test_blank_value_is_rejected(self):
        content = VALID.replace("| Reviewer | `codex/gpt-5.4` |", "| Reviewer |  |")
        self.assertTrue(any("Reviewer" in p for p in problems(content)))

    def test_missing_required_row_is_rejected(self):
        content = VALID.replace("| Fresh context? | yes |\n", "")
        self.assertTrue(any("Fresh context?" in p for p in problems(content)))


class AssertedIndependenceIsCrossChecked(unittest.TestCase):
    def test_cannot_claim_independent_while_authoring(self):
        content = VALID.replace(
            "| Authored the change? | no |", "| Authored the change? | yes |"
        )
        self.assertTrue(any("authored the change" in p for p in problems(content)))

    def test_cannot_claim_independent_without_fresh_context(self):
        content = VALID.replace("| Fresh context? | yes |", "| Fresh context? | no |")
        self.assertTrue(any("fresh context" in p for p in problems(content)))


class DisproveItPassIsChecked(unittest.TestCase):
    def test_missing_disproved_section_is_rejected(self):
        content = VALID.split("## Disproved")[0]
        self.assertTrue(any("Disproved" in p for p in problems(content)))

    def test_template_example_row_alone_is_rejected(self):
        content = VALID.replace(
            "| suspected N+1 in the loop | the association is preloaded in the scope |",
            "| what was suspected | the code or test that shows it is fine |",
        )
        self.assertTrue(any("Disproved" in p for p in problems(content)))

    def test_findings_with_only_the_template_row_is_rejected(self):
        content = VALID.replace(
            "| 1 | high | off-by-one in the cursor | fixed in `abc1234` |",
            "| 1 | high / medium / low | what the reviewer said | fixed in `<sha>` |",
        )
        self.assertTrue(any("Findings" in p for p in problems(content)))


class EscalationIsAValidOutcome(unittest.TestCase):
    """Handing work back must be a complete record, not a shortfall.

    If the honest path is harder than fabricating one, the mechanism produces
    exactly the fabrications it exists to prevent.
    """

    ESCALATED = """# Review record

## Provenance

| Field | Value |
|-------|-------|
| Date (UTC) | 2026-09-08 |
| Commit(s) reviewed | `abc1234` |
| Reviewer | `claude/opus-5` |
| Authored the change? | no |
| Fresh context? | yes |
| Independent? | yes |
| Escalated to human? | yes - the migration's backfill semantics need domain knowledge I do not have |
"""

    def test_escalated_record_needs_no_findings(self):
        self.assertEqual(problems(self.ESCALATED), [])

    def test_escalated_record_needs_no_disproved_section(self):
        self.assertNotIn(
            "Disproved", " ".join(problems(self.ESCALATED))
        )

    def test_escalation_without_a_reason_is_rejected(self):
        content = self.ESCALATED.replace(
            "| Escalated to human? | yes - the migration's backfill semantics "
            "need domain knowledge I do not have |",
            "| Escalated to human? | yes |",
        )
        found = problems(content)
        self.assertTrue(any("no reason" in p for p in found), found)

    def test_not_escalated_still_requires_findings_and_disproved(self):
        self.assertTrue(problems(self.ESCALATED.replace(
            "| Escalated to human? | yes - the migration's backfill semantics "
            "need domain knowledge I do not have |",
            "| Escalated to human? | no |",
        )))


class SectionParsing(unittest.TestCase):
    def test_section_stops_at_the_next_heading(self):
        self.assertNotIn("Disproved", section(VALID, "Findings"))

    def test_table_rows_drops_the_header(self):
        labels = [label for label, _ in table_rows(section(VALID, "Provenance"))]
        self.assertNotIn("Field", labels)
        self.assertIn("Reviewer", labels)


if __name__ == "__main__":
    unittest.main()
