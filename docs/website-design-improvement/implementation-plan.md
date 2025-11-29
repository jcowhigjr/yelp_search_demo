
## Problem statement
The `Website Design Improvement` React/Vite prototype defines a cleaner, more cohesive UI for search, results, detail, favorites, and auth flows. The production Rails app currently uses a Materialize-centric layout with partially aligned tokens, leading to a mismatch between the intended design and the live experience.

We need a low-tech-debt, incremental plan to port the visual and interaction patterns from the prototype into the Rails app, without introducing React or disrupting existing behavior, tests, or Hotwire/Turbo integrations.

## Current state summary

* **Search flow**
  * `searches#new` renders a basic search form using `app/views/searches/new.html.erb` and `_form.html.erb`.
  * `searches#show` renders the search results via `app/views/searches/show.html.erb` and `_results.html.erb`.
  * System tests in `test/system/searches_test.rb` cover anonymous search flows and re-query behavior.
* **Coffeeshop views**
  * `app/views/coffeeshops/_coffeeshop.html.erb` renders individual coffeeshop cards inside Materialize grid columns.
  * `app/views/coffeeshops/show.html.erb` displays the coffeeshop detail page with image, address, phone, Yelp link, rating, favorites, and reviews.
* **Layout and styles**
  * `app/views/layouts/application.html.erb` uses Materialize CSS, Tailwind, and shared `page-name` and `page-text` classes from `app/assets/stylesheets/application.css`.
  * `.coffeeshop-card` and related CSS already support dark mode via CSS variables.
* **Prototype**
  * `Website Design Improvement/` contains a React/Tailwind prototype with `SearchPage`, `ResultsPage`, `DetailPage`, `FavoritesPage`, `Navigation`, and `Footer` components.
  * It defines reusable visual patterns such as a search hero, search bar, card grid, and detail layout.

## Constraints and goals

* Do not introduce React or Vite into the Rails app; use ERB + Tailwind + existing CSS.
* Maintain all existing controller behavior and routing.
* Keep changes small and test-backed, suitable for focused PRs.
* Reuse existing tokens and classes (`page-name`, `page-text`, `.coffeeshop-card`, color variables) to avoid parallel design systems.
* Respect existing Turbo streams and frames.

## Phases

### Phase 1: Search hero and search bar alignment (DONE)

* Update `app/views/searches/new.html.erb` to:
  * Wrap content in a `container mx-auto px-4 py-8`-style layout.
  * Add a hero section with a large heading (e.g., "COFFEE NEAR YOU!") and supporting copy (e.g., "Find the best coffee shops in your area").
  * Center the existing search form under the hero using `page-name` and `page-text` for typography.
* Refactor `app/views/searches/_form.html.erb` to:
  * Use an inline-flex container with border, rounded corners, and shadow for the search bar.
  * Include a search icon, text input, clear action, and primary submit action, preserving current form helpers and geolocation fields.
* **Tests**
  * Extend `test/controllers/searches_controller_test.rb` to assert the hero heading and presence of the `search[query]` input on `#new`.

### Phase 2: Results grid and coffeeshop card alignment (DONE)

* **Coffeeshop card partial**
  * Keep using `app/views/coffeeshops/_coffeeshop.html.erb` as the single partial for coffeeshop cards.
  * Ensure the markup uses `page-text` and `.coffeeshop-card` for typography and background, aligning with the prototype card styling while preserving favorites, address, phone, and links.
* **Results grid**
  * Update `app/views/searches/_results.html.erb` to:
    * Preserve the heading and empty-state messaging.
    * Wrap the list of coffeeshops in a `.row` so each `_coffeeshop` column forms a clear grid of cards.
* **Tests**
  * Extend `test/controllers/searches_controller_test.rb` `#show` to assert that at least one `.coffeeshop-card` is rendered when results are present.

### Phase 3: Coffeeshop detail page layout alignment (DONE)

* **Context**
  * Use `Website Design Improvement/src/components/pages/DetailPage.tsx` as the visual reference.
  * Current view is `app/views/coffeeshops/show.html.erb` with a Materialize row/column layout.

* **Changes**
  * Restructure `coffeeshops/show.html.erb` into a layout that:
    * Uses a two-column layout on large screens (image on one side, details on the other) while remaining single-column on small screens.
    * Applies `page-name` and `page-text` to the title and key copy for visual consistency.
    * Groups address, phone, and Yelp link into clearly delineated sections similar to the prototype's icon + text rows.
    * Keeps favorites and reviews behavior unchanged, but improves spacing and grouping to mirror the prototype's "About" and "Reviews" sections.

* **Tests**
  * Update or add a system test (e.g., in `test/system/coffeeshops_test.rb`) that:
    * Navigates from a search result to a coffeeshop show page.
    * Asserts presence of the title, address, phone, Yelp link, and at least one review card when data exists.

### Phase 4: Favorites page layout and empty state (IMPLEMENTED IN USER PROFILE)

* **Context**
  * Use the prototype's `FavoritesPage` layout as guidance.
  * Identify the existing favorites view (e.g., `app/views/user_favorites/index.html.erb` or similar) and how it currently renders coffeeshops.

* **Changes**
  * Update the favorites view to:
    * Introduce a "My Favorites" heading using `page-name`.
    * Show a friendly empty state when there are no favorites, with copy encouraging users to search and a button/link back to the main search page.
    * When favorites exist, render them using the shared `_coffeeshop` partial in a grid layout similar to the search results.

* **Tests**
  * Add or extend a system test that:
    * Logs in a user.
    * Covers both empty and non-empty favorites states, asserting the header text and presence of coffeeshop cards when applicable.

### Phase 5: Navigation and footer polish (PARTIALLY IMPLEMENTED)

* **Navigation**
  * Adjust `app/views/layouts/_navbar.html.erb` to:
    * Use existing color tokens and font stack for the brand and links.
    * Align link styles with the prototype's `Navigation` component while preserving Materialize's mobile sidenav behavior and current links (logout, profile, search).
    * Leverage `.language-nav__link` and related classes already defined in `application.css` where appropriate.

* **Footer**
  * Update the footer partial (e.g., `app/views/layouts/_footer.html.erb`) to:
    * Use a simple structure similar to the prototype's footer: left-aligned copyright, right-aligned small links (About, Contact, Privacy).
    * Ensure it respects dark mode variables and existing layout constraints.

* **Tests**
  * Extend or add a system test (for example in `test/system/navigation_test.rb`) to assert that the main nav and footer links render and are clickable for a logged-in user.

### Phase 6: Theme toggle (DONE) and auth form refinement

* **Theme toggle – IMPLEMENTED**
  * Current implementation:
    * Stimulus controller at `app/javascript/controllers/theme_controller.js`.
    * Toggle button in `app/views/layouts/application.html.erb` with `data-controller="theme"`, `data-action="click->theme#toggle"`, and `aria-label="Toggle theme"`.
    * CSS variables and Tailwind utilities in `app/assets/tailwind/application.css` and `app/assets/stylesheets/application.css` using `data-theme`.
    * System test `test/system/theme_toggle_test.rb` verifies toggling and localStorage persistence.
  * Future refinements (optional): adjust visual styling or icon treatment of the toggle if the design prototype changes.

* **Auth forms – PARTIALLY ALIGNED**
  * Current state:
    * `app/views/sessions/new.html.erb` and `app/views/users/new.html.erb` already use centered card layouts with `page-name`, `page-text`, and Tailwind-style utility classes for inputs and buttons.
  * Remaining refinement:
    * Tighten spacing, border radii, and typography to more closely match the prototype's `LoginPage` and `SignupPage` if needed.
    * Ensure error states and third-party auth buttons remain visually consistent across login and signup.

* **Tests**
  * Ensure login/logout and signup system tests continue to pass and that error messages remain visible and accessible.

## Execution approach

* Implement one phase at a time, keeping each phase small enough for a focused PR.
* After each phase:
  * Run targeted tests (controller and system tests) related to the changed views.
  * Visually sanity-check pages locally when feasible.
* When ready to publish work:
  * Create a dedicated feature branch for the phase.
  * Commit only the files related to that phase with a clear message.
  * Open a PR that links back to the overarching "Website Design Improvement" issue and notes which phase in this plan it implements.
