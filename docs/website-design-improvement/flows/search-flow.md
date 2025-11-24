# Search Flow – Website Design Improvement

## Goal

Align the search entry and results experience with the prototype while preserving all existing behavior and routes.

## Surfaces

- Search landing: `searches#new`
  - View: `app/views/searches/new.html.erb`
  - Partial: `app/views/searches/_form.html.erb`
- Search results: `searches#show`
  - View: `app/views/searches/show.html.erb`
  - Partial: `app/views/searches/_results.html.erb`

## UX expectations

- Hero section on `searches#new` with:
  - Large title (e.g., “COFFEE NEAR YOU!”)
  - Supporting subtitle (plain `page-text`)
- Centered search bar with:
  - Search icon
  - Text input for query
  - Geolocation controls preserved
  - Primary submit button
- Results page with:
  - Clear heading showing the query or context
  - Grid of coffeeshop cards rendered via `_coffeeshop` partial

## Constraints

- **Do not change** controller logic or routes.
- **Do not change** parameter names (`search[query]`, geolocation fields).
- **Do not introduce** new JS frameworks; use existing Stimulus/Hotwire only if needed.
- Reuse typography and color tokens: `page-name`, `page-text`, `.coffeeshop-card`.

## Tests to touch

- Controller tests: `test/controllers/searches_controller_test.rb`
- System tests: `test/system/searches_test.rb`

## Agent checklist

When working on search-related changes:

1. Read this document plus `implementation-plan.md` Phase 1–2.
2. Modify **only** the views/partials listed above.
3. Keep all form fields and routes intact.
4. Ensure `_coffeeshop` is the single source for coffeeshop cards.
5. Update/extend tests to assert the presence of:
   - Hero heading on `searches#new`.
   - `.coffeeshop-card` elements on `searches#show` when results exist.
6. Run `mise exec -- bin/rails test test/controllers/searches_controller_test.rb test/system/searches_test.rb` before opening a PR.
