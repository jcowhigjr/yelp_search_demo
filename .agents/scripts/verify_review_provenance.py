#!/usr/bin/env python3
"""Verify the audit trail for locally-requested reviews (Route B in docs/AGENTS.md).

Any commit carrying a `Review-record:` trailer must point at a record under
docs/reviews/ that is genuinely filled in. This checks the paper trail, not the
quality of the review - no program can do the latter.

Placeholder detection reads the values out of docs/reviews/TEMPLATE.md at
runtime and treats a record cell equal to the template's cell as unfilled.
An earlier version hardcoded a list of placeholder strings, which silently
stopped covering the template every time a row was added to it. Deriving the
list from the template is self-maintaining.

Escalation is a first-class outcome. A record may say the reviewer stopped and
handed the change to a human; that is an honest finish, not a shortfall, and it
passes structurally. Only the DoD review box stays unticked. Fabricating a
review to fill a checkbox is the failure this is meant to make pointless.

Usage:
    verify_review_provenance.py [<git range>] [--require-record]
"""

import re
import subprocess
import sys
from pathlib import Path

TEMPLATE = "docs/reviews/TEMPLATE.md"

# Provenance rows that must be answered for the record to mean anything.
REQUIRED_FIELDS = (
    "Date (UTC)",
    "Commit(s) reviewed",
    "Reviewer",
    "Authored the change?",
    "Fresh context?",
    "Independent?",
)

# A record may declare that the reviewer stopped rather than guess. When it
# does, Findings/Disproved are allowed to be empty - there was no review to
# report, and inventing one is precisely what we are trying to make pointless.
ESCALATION_FIELD = "Escalated to human?"

SHA = re.compile(r"\b[0-9a-f]{7,40}\b")

ROW = re.compile(r"^\|(?P<label>[^|]+)\|(?P<value>.*)\|\s*$")
SEPARATOR = re.compile(r"^\|[\s:|-]+\|\s*$")


def git(*args, **kwargs):
    return subprocess.run(
        ["git", *args], capture_output=True, text=True, **kwargs
    )


def repo_root():
    result = git("rev-parse", "--show-toplevel")
    if result.returncode != 0:
        sys.exit("Not inside a git repository.")
    return Path(result.stdout.strip())


def section(text, name):
    """Body of a `## <name>` section, up to the next heading.

    Matches a heading that *starts with* the name, so `## Provenance (self-review)`
    still counts. Requiring an exact match let a renamed heading silently disable
    every check inside it.
    """
    lines = text.splitlines()
    wanted = name.casefold()
    out, inside = [], False
    for line in lines:
        if line.startswith("## "):
            inside = line[3:].strip().casefold().startswith(wanted)
            continue
        if line.startswith("# "):
            inside = False
            continue
        if inside:
            out.append(line)
    return "\n".join(out)


def table_rows(body):
    """[(label, value)] for markdown table rows, header and separator dropped."""
    rows = []
    for line in body.splitlines():
        if SEPARATOR.match(line):
            continue
        match = ROW.match(line.strip())
        if not match:
            continue
        label = match.group("label").strip()
        value = match.group("value").rsplit("|", 0)[0].strip()
        if label.casefold() in {"field", "#"} or not label:
            continue
        rows.append((label, value))
    return rows


def provenance_map(text):
    return {label: value for label, value in table_rows(section(text, "Provenance"))}


def normalize(value):
    return " ".join(value.split()).casefold()


def data_rows(text, name):
    """Rows of a section's table, minus the header row."""
    body = section(text, name)
    rows = [
        line.strip()
        for line in body.splitlines()
        if line.strip().startswith("|") and not SEPARATOR.match(line.strip())
    ]
    return [r for r in rows if not re.match(r"^\|\s*(#|Candidate finding)\s*\|", r)]


def escalated(content):
    """True when the record declares the reviewer handed back to a human."""
    value = normalize(provenance_map(content).get(ESCALATION_FIELD, ""))
    return value.startswith("yes")


def commits_in_range(rng):
    return set(git("rev-list", rng).stdout.split())


def sha_consistency(content, sha, range_shas):
    """Reject a record that names a commit which does not exist.

    Deliberately narrow. An earlier version also demanded that every sha belong
    to the change under review, which flagged a record for citing its own base
    commit - legitimate context, not a false claim. Requiring membership means
    guessing which mentions are claims and which are references, and guessing
    from prose is how the other heuristics in this file went wrong. Existence is
    something we can actually prove: a sha that resolves to nothing was invented.
    """
    problems = []
    claimed = provenance_map(content).get("Commit(s) reviewed", "")
    for h in {h for h in SHA.findall(claimed) if not h.isdigit()}:
        if git("rev-parse", "--verify", "--quiet", f"{h}^{{commit}}").returncode != 0:
            problems.append(f"names commit `{h}`, which does not exist in this repo")
    return problems


def ordering_problem(sha, record):
    """A record committed before the code it reviews was written is fabricated."""
    record_commit = git(
        "log", "-1", "--format=%ct", sha, "--", record
    ).stdout.strip()
    code_commit = git("show", "-s", "--format=%ct", sha).stdout.strip()
    if not record_commit or not code_commit:
        return None
    if int(record_commit) < int(code_commit):
        return (
            "the review record predates the commit it reviews; a review cannot "
            "have happened before the code existed"
        )
    return None


def check_record(short, record, content, template):
    """Return a list of problems; empty means the record is valid."""
    problems = []
    tmpl_prov = {k: normalize(v) for k, v in provenance_map(template).items()}
    record_prov = provenance_map(content)
    normalized = {k: normalize(v) for k, v in record_prov.items()}

    for field in REQUIRED_FIELDS:
        if field not in record_prov:
            problems.append(f"Provenance table is missing the '{field}' row")
        elif not normalized[field]:
            problems.append(f"'{field}' is blank")
        elif field in tmpl_prov and normalized[field] == tmpl_prov[field]:
            problems.append(f"'{field}' still holds the template's placeholder text")

    # A record may not simply assert independence it does not have.
    independent = normalized.get("Independent?", "")
    authored = normalized.get("Authored the change?", "")
    fresh = normalized.get("Fresh context?", "")
    if independent.startswith("yes"):
        if authored.startswith("yes"):
            problems.append(
                "claims 'Independent? yes' while also recording that the reviewer "
                "authored the change"
            )
        if fresh.startswith("no"):
            problems.append(
                "claims 'Independent? yes' while also recording that the reviewer "
                "did not start from a fresh context"
            )

    if escalated(content):
        # An honest hand-back needs a reason, not findings.
        reason = normalize(record_prov.get(ESCALATION_FIELD, ""))
        if reason in {"", "yes", "no"}:
            problems.append(
                f"'{ESCALATION_FIELD}' says yes but gives no reason; say what you "
                "were not confident about"
            )
        return problems

    for name in ("Findings", "Disproved"):
        rows = data_rows(content, name)
        template_rows = {normalize(r) for r in data_rows(template, name)}
        real = [r for r in rows if normalize(r) not in template_rows]
        if not section(content, name).strip():
            problems.append(f"has no '{name}' section")
        elif not real:
            if name == "Disproved" and re.search(
                r"\bnone\b", section(content, name), re.I
            ):
                continue
            problems.append(
                f"'{name}' section contains only the template's example row"
            )

    return problems


def main():
    root = repo_root()
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    require_record = "--require-record" in sys.argv
    rng = args[0] if args else None

    if rng is None:
        if git("rev-parse", "--verify", "--quiet", "HEAD@{upstream}").returncode == 0:
            rng = "HEAD@{upstream}..HEAD"
        elif git("rev-parse", "--verify", "--quiet", "origin/develop").returncode == 0:
            base = git("merge-base", "HEAD", "origin/develop").stdout.strip()
            if not base:
                print("ℹ️  No comparison point; skipping review provenance check.")
                return 0
            rng = f"{base}..HEAD"
        else:
            print("ℹ️  No comparison point; skipping review provenance check.")
            return 0

    template_path = root / TEMPLATE
    if not template_path.exists():
        print(f"❌ Missing {TEMPLATE}; cannot tell placeholders from real content.")
        return 1
    template = template_path.read_text(encoding="utf-8")

    revs = git("rev-list", rng).stdout.split()
    range_shas = set(revs)
    errors = checked = 0

    for sha in revs:
        short = git("rev-parse", "--short", sha).stdout.strip()
        trailers = git(
            "show", "-s", "--format=%(trailers:key=Review-record,valueonly)", sha
        ).stdout

        for record in (line.strip() for line in trailers.splitlines()):
            if not record:
                continue
            checked += 1

            # Prefer the file as of that commit; an audit trail should not break
            # because the record was later moved.
            shown = git("show", f"{sha}:{record}")
            if shown.returncode == 0:
                content = shown.stdout
            elif (root / record).exists():
                content = (root / record).read_text(encoding="utf-8")
            else:
                print(f"❌ {short}: Review-record points at a missing file: {record}")
                errors += 1
                continue

            if record == TEMPLATE:
                print(f"❌ {short}: Review-record points at the template itself.")
                errors += 1
                continue

            problems = check_record(short, record, content, template)
            problems += sha_consistency(content, sha, range_shas)
            ordering = ordering_problem(sha, record)
            if ordering:
                problems.append(ordering)
            if problems:
                print(f"❌ {short}: {record}")
                for problem in problems:
                    print(f"     - {problem}")
                errors += 1
                continue

            if escalated(content):
                print(f"⚠️  {short}: {record} ESCALATED to a human reviewer.")
                print("     Recorded honestly. The DoD review step needs a human.")
            elif normalize(provenance_map(content).get("Independent?", "")).startswith("no"):
                print(f"⚠️  {short}: {record} records a NON-INDEPENDENT review.")
                print("     Provenance is valid, but the DoD review step is not satisfied.")
            else:
                print(f"✅ {short}: review provenance recorded in {record}")

    if errors:
        print()
        print(f"✘ Review provenance check failed: {errors} record(s).")
        print("  See 'Obtain an independent review' in docs/AGENTS.md"
              f" and {TEMPLATE}.")
        return 1

    if checked == 0:
        if require_record:
            print("❌ No commit in this change carries a `Review-record:` trailer.")
            print()
            print("  Every change needs one. If you did not review it, say so - copy")
            print(f"  {TEMPLATE}, set '{ESCALATION_FIELD}' to yes with a reason, and")
            print("  reference it with a Review-record trailer. Handing work back is a")
            print("  valid outcome; an unrecorded change is not.")
            return 1
        print("ℹ️  No commits carry a Review-record trailer; nothing to verify.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
