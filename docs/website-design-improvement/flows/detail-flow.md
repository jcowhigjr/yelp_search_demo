# Detail Flow – Coffeeshop Page

## Goal

Align the coffeeshop detail page layout with the prototype’s detail view while preserving all existing interactions (favorites, reviews, Yelp link, etc.).

## Surface

- Coffeeshop detail: `coffeeshops#show`
  - View: `app/views/coffeeshops/show.html.erb`

## UX expectations

- Two-column layout on large screens:
  - Left: coffeeshop image
  - Right: name, address, phone, Yelp link, rating, favorites CTA
- Single-column layout on small screens (stacked vertically).
- Clear grouping:
  - **About** section: address, phone, Yelp link, rating, favorites count
  - **Reviews** section: list of reviews plus review form when logged in

## Constraints

- **Do not change** controller logic, routes, or model methods.
- Keep Turbo frames and favorites logic intact (`turbo_frame_tag :user_favorite`).
- Reuse `page-name` and `page-text` for headings/body copy.
- Keep `.review-container` structure compatible with existing tests.

## Tests to touch

- System tests: `test/system/coffeeshops_test.rb`

## Agent checklist

When working on detail-page changes (Phase 3):

1. Read this document plus `implementation-plan.md` Phase 3.
2. Restructure only the **HTML layout** in `coffeeshops/show.html.erb`.
3. Do **not** change form actions, routes, or Turbo frame IDs.
4. Ensure the page still exposes:
   - Coffeeshop name as main heading
   - Address link (Google Maps)
   - Phone link (tel:)
   - Yelp link
   - Rating widget
   - Favorites add/remove buttons when logged in
   - Reviews list and review form
5. Update/extend system tests to assert the above elements are present.
6. Run `mise exec -- bin/rails test test/system/coffeeshops_test.rb` before opening a PR.
