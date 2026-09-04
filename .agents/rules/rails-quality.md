# Rails 8 & Testing Standards Rule

This rule guides Gemini models working on Rails 8, Hotwire, and Cuprite testing in `yelp_search_demo`.

---

## 1. Hotwire & Frontend Conventions
* **Turbo Frames & Streams**:
  - Target specific Turbo Frame IDs to update partial UI sections without full page reloading.
  - Test Turbo Frame navigation and DOM updates in system tests.
* **Stimulus Controllers**:
  - Placed under `app/javascript/controllers/` (e.g. `geolocation_controller.js`, `theme_controller.js`).
  - Rely on semantic HTML attributes (`data-controller`, `data-action`, `data-[controller]-target`).
* **Tailwind CSS v4**:
  - Always run `mise exec -- scripts/verify-tailwind-build.sh` after modifying stylesheets or classes to confirm production compilation.

---

## 2. Empirical Test Execution Protocols
* **Unit & Controller Tests**:
  - Command: `mise run test`
  - Prepare DB: `mise run test-prepare`
* **Cuprite System Tests**:
  - Preferred task: `mise run test-system` (encapsulates headless flags, tmpdir, and Cuprite driver)
  - Direct command: `HEADLESS=true CUPRITE=true APP_HOST=localhost mise exec -- bin/rails test:system`
  - Wait for Turbo and dynamic elements using Capybara matchers (`assert_selector`, `assert_text`) instead of arbitrary `sleep`.
* **Security & Linter Audits**:
  - `mise run lint` (RuboCop)
  - `mise run brakeman` (Brakeman)
