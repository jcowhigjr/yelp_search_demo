# UI Integration Sub-Issues (Issue #1002)

Issue #1002 (planning) is now split into the eight sub-issues below so each UI phase can proceed in parallel. Branch names and worktree paths follow the branch plan for this integration track.

| Issue # | Scope | Branch | Worktree path | Status | Primary tests |
| --- | --- | --- | --- | --- | --- |
| #1033 | Phase 1 – Search hero & bar | `feature/ui-phase1-hero` | `/private/tmp/ui-phase1-hero` | Done | `test/controllers/searches_controller_test.rb`, `test/system/searches_test.rb` |
| #1034 | Phase 2 – Results grid & card | `feature/ui-phase2-results` | `/private/tmp/ui-phase2-results` | Done | `test/controllers/searches_controller_test.rb`, `test/system/searches_test.rb` |
| #1035 | Phase 3 – Coffeeshop detail | `feature/ui-phase3-detail` | `/private/tmp/ui-phase3-detail` | Done | `test/system/coffeeshops_test.rb` |
| #1036 | Phase 4 – Favorites page | `feature/ui-phase4-favorites` | `/private/tmp/ui-phase4-favorites` | Implemented in user profile | `test/system/favorites*_test.rb` (or equivalent) |
| #1037 | Phase 5 – Navigation polish | `feature/ui-phase5-nav-footer` | `/private/tmp/ui-phase5-nav-footer` | Partially implemented | `test/system/navigation_test.rb` |
| #1038 | Phase 5 – Footer polish | `feature/ui-phase5-nav-footer` | `/private/tmp/ui-phase5-nav-footer` | Partially implemented | `test/system/navigation_test.rb` |
| #1039 | Phase 6 – Theme toggle | `feature/ui-phase6-theme` | `/private/tmp/ui-phase6-theme` | Done | `test/system/theme_toggle_test.rb` |
| #1040 | Phase 6b – Auth forms | `feature/ui-phase6b-auth` | `/private/tmp/ui-phase6b-auth` | Partially aligned | Login/Signup system tests |

## Issue specs

### #1033 – Phase 1: Search hero and search bar alignment
- Update `app/views/searches/new.html.erb` with hero layout (`page-name`, `page-text`, centered form).
- Refine `_form.html.erb` into inline-flex search bar with icon, input, clear, submit; keep geolocation fields and helpers.
- Tests: controller asserts hero heading and `search[query]`; system tests continue to pass.

### #1034 – Phase 2: Results grid and coffeeshop card alignment
- Keep `_coffeeshop.html.erb` as single card partial using `page-text` and `.coffeeshop-card`.
- Wrap results in grid/row structure inside `_results.html.erb` while preserving headings and empty state.
- Tests: controller ensures `.coffeeshop-card` renders when results exist.

### #1035 – Phase 3: Coffeeshop detail page layout alignment
- Restructure `coffeeshops/show.html.erb` into two-column (lg) / single-column (sm) layout using prototype cues.
- Group About section (address, phone, Yelp link, rating, favorites) and Reviews section with spacing polish.
- Preserve Turbo frames/favorites/reviews behavior.
- Tests: system test navigates from search to show page and asserts title, address, phone, Yelp link, reviews present.

### #1036 – Phase 4: Favorites page layout and empty state
- Add “My Favorites” heading (`page-name`), friendly empty state with CTA back to search.
- When favorites exist, render grid via shared `_coffeeshop` partial.
- Tests: logged-in system test covers empty and non-empty states, asserting header, empty copy, CTA, and cards.

### #1037 – Phase 5: Navigation polish
- Adjust `_navbar.html.erb` to match prototype styling while keeping Materialize mobile sidenav behavior and existing links.
- Reuse color tokens and `.language-nav__link` classes where appropriate.
- Tests: system navigation test confirms main nav links render and are clickable when logged in.

### #1038 – Phase 5: Footer polish
- Update `_footer.html.erb` to simple left/right layout (copyright + small links) honoring dark-mode variables.
- Keep layout constraints compatible with existing pages.
- Tests: extend navigation/footer system test to assert footer links render.

### #1039 – Phase 6: Theme toggle (implemented)
- Current implementation lives in `theme_controller.js` and application layout; continue to honor `data-theme` variables.
- Further refinements are optional styling adjustments for the toggle control.
- Tests: `test/system/theme_toggle_test.rb` already exercises toggle and localStorage behavior.

### #1040 – Phase 6b: Auth form refinement
- Tighten spacing/typography in `sessions#new` and `users#new` to match prototype login/signup.
- Keep field names, routes, error handling intact; ensure messages remain visible.
- Tests: login/logout and signup system tests must pass; verify error states manually if updated.
