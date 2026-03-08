# Website Design Improvement – Agents Playbook

> Tracked in GitHub: [Issue #1002 – Plan: Integrate Website Design Improvement prototype into Rails UI](https://github.com/jcowhigjr/yelp_search_demo/issues/1002)

This playbook explains **how agents should work this issue in parallel** without stepping on each other, and how to keep PRs small, test-backed, and aligned with the design prototype.

For the standing autonomous execution loop, also read `design-loop.md`.

## High-level phases

Each phase should generally correspond to **one focused PR**:

1. Search hero and search bar alignment (DONE)
2. Results grid and coffeeshop card alignment (DONE)
3. Coffeeshop detail page layout alignment
4. Favorites page layout and empty state
5. Navigation and footer polish
6. Optional theme toggle and auth form refinement

Details for each phase live in:

- `implementation-plan.md` (overall breakdown)
- `flows/*.md` (per-flow UX and constraints)

## Parallelization model

Agents should treat each phase as an independent track, with these rules:

- **Do not modify controllers or models** unless explicitly required by the issue.
- **Do not introduce React/Vite** into the Rails app; use ERB + Tailwind + existing CSS.
- Prefer **view-only** changes (`app/views/**`, CSS) plus **tests**.
- For each phase:
  - Create a dedicated branch: `feature/website-design-<phase-name>`
  - Touch only the views/CSS/tests listed in that phase’s section.
  - Run the specific tests listed for that phase.

## Per-phase quick map

This is a routing table to help agents jump straight to the right files and tests.

### Phase 3 – Coffeeshop detail page

- **Primary views**
  - `app/views/coffeeshops/show.html.erb`
- **Key tests**
  - System: `test/system/coffeeshops_test.rb`
- **Flow doc**
  - `flows/detail-flow.md`

### Phase 4 – Favorites page

- **Primary views**
  - `app/views/user_favorites/index.html.erb` (or the actual favorites index view used in this app)
  - Any partial that renders favorite coffeeshops (ideally reusing `_coffeeshop`)
- **Key tests**
  - System: favorites-related system test (add or extend as described in `implementation-plan.md`)
- **Flow doc**
  - `flows/favorites-flow.md`

### Phase 5 – Navigation and footer

- **Primary views**
  - `app/views/layouts/_navbar.html.erb`
  - `app/views/layouts/_footer.html.erb`
- **Key tests**
  - System: navigation/footer system test (e.g., `test/system/navigation_test.rb`)
- **Flow docs**
  - `flows/search-flow.md` (for top-level navigation to search)

### Phase 6 – Theme toggle and auth forms (optional)

- **Primary views**
  - Auth: `app/views/sessions/new.html.erb`, `app/views/users/new.html.erb` (or equivalents)
  - Layout: element that receives `data-theme` for dark/light
- **Key tests**
  - Existing login/signup system tests
- **Flow docs**
  - `flows/auth-flow.md`

## Standard workflow for an agent

For any phase you pick up:

1. **Read the design docs**
   - `README.md`
   - `implementation-plan.md`
   - The relevant `flows/*.md` file
2. **Confirm scope**
   - Verify which phase and which files you are allowed to touch.
   - Ensure you are not overlapping with another active phase/branch.
3. **Create a feature branch**
   - Follow the project’s standard: `feature/website-design-<phase-name>`.
4. **Make view/CSS changes only**
   - Keep behavior (routes, controller actions, models) the same.
   - Focus on layout, spacing, typography, and structure.
5. **Update/add tests**
   - Prefer system tests that assert key elements exist and are wired correctly.
   - Keep tests resilient to minor cosmetic changes.
6. **Run targeted tests**
   - Run the tests listed in the phase (controller/system) before pushing.
7. **Open a PR**
   - Title: `Website Design Improvement – Phase X: <short description>`
   - Link to Issue #1002 and the specific flow doc.
   - Describe exactly which views and tests changed.

## Autonomous Design Teammate Workflow

When an agent is acting as the standing design teammate instead of picking an ad hoc phase:

1. Start with the repo rules and design docs listed in `design-loop.md`.
2. Compare production, the latest preview deploy, and Figma before choosing work.
3. Restrict autonomous changes to a single surface and to view/CSS/test scope only.
4. Use `#1228` as the retrospective thread and add a short "why this iteration" comment before coding.
5. Reuse an existing issue when possible; otherwise create one with explicit acceptance criteria first.
6. Re-run visual verification after deployment, not just locally.
7. Add a short retrospective comment to `#1228` after merge, including any instruction or skill gap discovered.

Current autonomous roadmap order:

1. Results-page parity (`#1737`)
2. Geolocation feedback (`#1221`)
3. Footer and utility controls (`#1218`, `#1195`)
4. Auth and favorites parity follow-up

## What “done” means for a phase

A phase is **done** when:

- The layout/structure of the targeted views matches the intent of the prototype, as described in the flow doc.
- All existing behavior is preserved (same routes, same forms, same buttons/links).
- Tests listed for the phase pass locally.
- The PR remains small and reviewable in under ~15 minutes.

## Coordination between agents

To allow parallel work:

- Prefer that each agent owns **one phase at a time**.
- Avoid touching shared partials (like `_coffeeshop`) in unrelated phases unless the change is clearly shared and documented.
- If two phases must both adjust a shared partial, coordinate via the GitHub issue or PR comments and update the docs here if the shared contract changes.

If additional flows or surfaces are added later, create new `flows/*.md` files and extend `implementation-plan.md` so future agents can follow the same pattern.
