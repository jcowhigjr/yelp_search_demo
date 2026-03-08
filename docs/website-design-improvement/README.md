# Website Design Improvement

> Tracked in GitHub: [Issue #1002 – Plan: Integrate Website Design Improvement prototype into Rails UI](https://github.com/jcowhigjr/yelp_search_demo/issues/1002)

## Purpose

- Capture the visual and interaction patterns from the Website Design Improvement prototype.
- Provide a concrete implementation plan for incrementally porting those patterns into the Rails app.
- Keep this work clearly scoped as **design / documentation**, not as code that needs to be analyzed by CodeQL or CI linters.

## Where this is used

- Referenced from the "Website Design Improvement" GitHub issue (link that issue here in the description / comments).
- Used as the single source of truth for how the new UI should look and behave.

## CodeQL and scanning behavior

To avoid static analysis noise from design prototypes:

- The repo includes a CodeQL config at `.github/codeql/codeql-config.yml` which:
  - Focuses CodeQL analysis on real app code (`app/**`, `config/**`, `lib/**`, `bin/**`).
  - Explicitly ignores this directory via:
    - `docs/website-design-improvement/**`
    - and also the historical root-level folder name `Website Design Improvement/**`.
- `.gitattributes` marks this docs directory as documentation:
  - `docs/website-design-improvement/** linguist-documentation`

This means you are free to place design assets and notes here (including screenshots, PDFs, or prototype snippets) without them being treated as primary app code by GitHub.

## Suggested structure

You can organize this directory as follows:

- `README.md` (this file): overview, purpose, and links to the GitHub issue.
- `screenshots/`: exported PNGs or JPEGs of key flows
  - Search
  - Results
  - Coffeeshop detail
  - Favorites
  - Auth (login / signup)
- `flows/`: optional markdown files describing each flow in more detail
  - `search-flow.md`
  - `detail-flow.md`
  - `favorites-flow.md`
  - `auth-flow.md`
- `prototype/` (optional): if you choose to check in a React/Vite or other prototype for local reference only.

When adding a runnable prototype under `prototype/`, keep in mind:

- It is **not** part of the production app.
- It is **out of scope** for CodeQL scanning due to the repo-wide CodeQL config.
- Local developers can explore it as a reference for layout and behavior, then implement the real changes in Rails views (`app/views/...`) using ERB + Tailwind + existing CSS.

## Implementation plan (high-level)

For detailed responsibilities and how to split this work across multiple engineering agents, see:

- `agents-playbook.md` – how to parallelize work and structure PRs
- `design-loop.md` – standing operating model for the autonomous design teammate loop
- `flows/` – per-flow UX docs (search, detail, favorites, auth)

If you want to keep a compact version of the implementation plan here, you can summarize it like this:

1. **Search hero and search bar alignment**
   - Modern hero section on `searches#new`.
   - Search bar layout aligned with the prototype, using existing Rails form helpers.
2. **Results grid and coffeeshop card alignment**
   - Align card layout and grid structure with the prototype while keeping behavior unchanged.
3. **Coffeeshop detail page layout alignment**
   - Two-column layout on large screens, single-column on small screens.
4. **Favorites page layout and empty state**
   - Use shared card patterns and friendly empty-state messaging.
5. **Navigation and footer polish**
   - Align nav and footer styling with the prototype using existing tokens.
6. **Optional theme toggle and auth form refinement**
   - Use existing dark-mode variables and consistent form patterns.

The full, detailed implementation plan can be pasted or refined here as needed, so that reviewers and other engineers can reason about the design work directly in the repo.

## Autonomous Design Loop

The repository now uses a standing design-loop workflow for small UI iterations.

- Retrospective / project-brain issue: `#1228`
- Active iteration issue: `#1737`
- Manual kickoff prompt: `Run the next design iteration.`
- Planning-only prompt: `Plan the next design iteration only; do not implement.`

See `design-loop.md` for the execution rules, guardrails, and definition of done.
