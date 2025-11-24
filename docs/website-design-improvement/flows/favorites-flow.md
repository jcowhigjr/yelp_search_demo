# Favorites Flow – Website Design Improvement

## Goal

Align the favorites list page with the prototype’s Favorites view, using shared coffeeshop card patterns and a friendly empty state.

## Surfaces

- Favorites index (user’s favorites list)
  - View: `app/views/user_favorites/index.html.erb` (or the actual favorites index view)
  - Partials: should reuse `app/views/coffeeshops/_coffeeshop.html.erb` for cards when possible

## UX expectations

- Heading: “My Favorites” using `page-name` styling.
- When the user has **no favorites**:
  - Show an empty state with copy that explains there are no favorites yet.
  - Provide a clear CTA (link/button) back to the search page.
- When the user **has favorites**:
  - Render a grid of coffeeshop cards using the shared `_coffeeshop` partial.

## Constraints

- Do not change favorites behavior (how favorites are created/destroyed).
- Reuse `_coffeeshop` for visual consistency with search results.
- Keep routes and controller actions unchanged.

## Tests to touch

- System tests for favorites behavior (add or extend a system test file, e.g., `test/system/favorites_test.rb` or similar).

## Agent checklist

When working on favorites-page changes (Phase 4):

1. Read this document plus `implementation-plan.md` Phase 4.
2. Confirm which view is the actual favorites index in this app.
3. Introduce or refine:
   - “My Favorites” heading
   - Empty-state block with copy + CTA
   - Grid of cards when favorites exist (via `_coffeeshop`).
4. Add or extend a system test that:
   - Logs in as a user.
   - Exercises both the empty and non-empty favorites states.
   - Asserts the heading, empty-state copy, CTA, and coffeeshop cards.
5. Run the relevant system tests via `mise exec -- bin/rails test test/system` (or the narrower favorites file) before opening a PR.
