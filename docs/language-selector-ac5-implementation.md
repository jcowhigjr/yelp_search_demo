# Language Selector System Tests Implementation (AC5)

**GitHub Issue:** #1137  
**Acceptance Criteria:** AC5  
**Date:** December 6, 2025

## Overview

This document summarizes the implementation of comprehensive system tests for the language selector functionality, specifically addressing AC5 requirements: locale switching, I18n.locale updates, HTML lang attribute changes, and non-interference with theme toggle and search functionality.

## Implementation Summary

### 1. System Tests (Rails/Capybara)

**File:** `test/system/locales_test.rb`

Added 7 new comprehensive system tests:

1. **Locale Switching Updates I18n.locale**
   - Verifies clicking language selector updates the locale
   - Confirms French content is displayed after switching
   - Validates URL contains correct locale path

2. **HTML Lang Attribute Updates**
   - Verifies initial `html[lang="en"]`
   - Confirms attribute updates to `html[lang="fr"]` after switching
   - Ensures page content loads correctly

3. **Translated Content Updates**
   - Verifies search placeholder translations across locales
   - Tests English → Spanish translation
   - Confirms translated content displays correctly

4. **Active Locale Styling**
   - Verifies active language link has correct CSS class
   - Tests class updates when switching locales
   - Confirms visual indication of current locale

5. **Non-Interference with Theme Toggle**
   - Verifies theme toggle button exists after language switch
   - Confirms theme toggle remains functional
   - Tests theme icon changes correctly

6. **Search Functionality Across Locales**
   - Verifies search input remains visible
   - Confirms placeholder text translates correctly
   - Tests search button remains enabled
   - Validates user can type in search input

7. **Multiple Locale Switches**
   - Tests all UI elements remain functional
   - Verifies Spanish → Portuguese switching
   - Confirms page structure preservation

### 2. Playwright E2E Tests

**File:** `test/e2e/language-selector-integration.spec.js`

Created 6 Playwright integration tests focusing on non-interference and cross-functionality:

1. **Language Selector Does Not Interfere with Theme Toggle**
   - Verifies theme button remains visible after language switch
   - Tests theme toggle functionality after switch
   - Confirms theme icon changes

2. **Search Functionality Remains Intact Across Locale Changes**
   - Tests search input visibility across English → French → Spanish
   - Verifies placeholder translations
   - Confirms search button remains enabled
   - Tests user input functionality

3. **Theme Toggle and Search Work Together After Multiple Locale Switches**
   - Combines theme and search testing
   - Tests multiple locale switches in sequence
   - Verifies all elements remain interactive

4. **HTML Lang Attribute Updates Without Breaking Functionality**
   - Tests lang attribute updates correctly
   - Verifies theme toggle works after lang change
   - Confirms search works after lang change

5. **Locale Switching Preserves Page Structure**
   - Tests all critical elements remain visible
   - Verifies elements are interactive, not just visible
   - Confirms page structure integrity

6. **I18n.locale Updates Reflected in Translated Content**
   - Verifies search placeholder translations
   - Tests HTML lang attribute matches locale
   - Confirms active language link styling

### 3. Configuration Files

**File:** `playwright.config.js`

- Configured Playwright test runner
- Set test directory to `./test/e2e`
- Configured timeout, retry, and screenshot settings
- Set base URL for tests

**File:** `package.json`

Added new test scripts:
```json
{
  "test:playwright": "playwright test",
  "test:playwright:headed": "playwright test --headed",
  "test:playwright:ui": "playwright test --ui",
  "test:playwright:integration": "playwright test test/e2e/language-selector-integration.spec.js"
}
```

### 4. Documentation

**File:** `test/e2e/PLAYWRIGHT_README.md`

- Comprehensive guide for running Playwright tests
- Installation instructions
- Debugging tips
- Best practices
- Comparison with Puppeteer tests

## Test Coverage

### System Tests (Rails)
- ✅ Locale switching updates I18n.locale
- ✅ HTML lang attribute changes correctly
- ✅ Translated content updates
- ✅ Active locale styling
- ✅ Theme toggle non-interference
- ✅ Search functionality preservation
- ✅ Multiple locale switches

### Playwright Tests
- ✅ Theme toggle non-interference (comprehensive)
- ✅ Search functionality across locales (comprehensive)
- ✅ Combined theme + search after switches
- ✅ HTML lang attribute + functionality preservation
- ✅ Page structure preservation
- ✅ Translated content verification

## Running Tests

### System Tests (Rails)

```bash
# Run all locale system tests
mise exec -- bin/rails test test/system/locales_test.rb

# Run specific test
mise exec -- bin/rails test test/system/locales_test.rb -n test_switching_locale_updates_I18n.locale
```

### Playwright Tests

```bash
# Install dependencies (one-time)
yarn install
npx playwright install

# Run all Playwright tests
yarn test:playwright

# Run in headed mode (see browser)
yarn test:playwright:headed

# Run integration tests only
yarn test:playwright:integration

# Interactive UI mode
yarn test:playwright:ui
```

## Dependencies Added

- `@playwright/test` (dev dependency)

## Files Modified

1. `test/system/locales_test.rb` - Added 7 new system tests
2. `package.json` - Added Playwright dependency and test scripts

## Files Created

1. `test/e2e/language-selector-integration.spec.js` - Playwright integration tests
2. `playwright.config.js` - Playwright configuration
3. `test/e2e/PLAYWRIGHT_README.md` - Playwright test documentation
4. `docs/language-selector-ac5-implementation.md` - This document

## Test Results

All tests pass successfully:

```
Running 11 tests in parallel using 3 processes
Run options: --seed 26259

# Running:

...........

Finished in 42.250241s, 0.2604 runs/s, 1.0414 assertions/s.
11 runs, 44 assertions, 0 failures, 0 errors, 0 skips
```

## Code Quality

- ✅ RuboCop: All offenses resolved
- ✅ Rails system tests: All passing
- ✅ Playwright tests: Ready to run (require Rails server)

## Acceptance Criteria Verification (AC5)

| Requirement | Status | Coverage |
|-------------|--------|----------|
| Locale switching updates I18n.locale | ✅ | System + Playwright tests |
| HTML lang attribute changes | ✅ | System + Playwright tests |
| Translated content displays correctly | ✅ | System + Playwright tests |
| Theme toggle non-interference | ✅ | System + Playwright tests |
| Search functionality preservation | ✅ | System + Playwright tests |
| Multiple locale switches work correctly | ✅ | System + Playwright tests |

## Related Files

- **Views:**
  - `app/views/layouts/application.html.erb` - HTML lang attribute
  - `app/views/layouts/_footer.html.erb` - Language selector
  - `app/views/searches/_form.html.erb` - Search input

- **Controllers:**
  - `app/controllers/concerns/locales.rb` - Locale handling
  - `app/controllers/application_controller.rb` - Around action

- **Routes:**
  - `config/routes.rb` - Locale scope configuration

- **Locales:**
  - `config/locales/*.yml` - Translations

## Future Enhancements

1. Add visual regression testing for locale-specific layouts
2. Test RTL language support (if added)
3. Add tests for locale persistence across navigation
4. Test keyboard navigation for language selector
5. Add accessibility (a11y) tests for language selector

## References

- GitHub Issue #1137
- [Rails System Testing Guide](https://guides.rubyonrails.org/testing.html#system-testing)
- [Playwright Documentation](https://playwright.dev/)
- [Capybara Documentation](https://rubydoc.info/github/teamcapybara/capybara)
