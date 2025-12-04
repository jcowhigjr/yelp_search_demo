# Playwright Tests

This directory contains Playwright end-to-end tests for the application.

## Overview

Playwright is a modern testing framework that provides reliable end-to-end testing across all major browsers. These tests verify critical user flows and functionality.

## Setup

### Install Dependencies

Playwright is already included in the project dependencies. To install Playwright browsers:

```bash
yarn playwright install
# or
npx playwright install
```

### Install System Dependencies (if needed)

On Linux, you may need to install additional system dependencies:

```bash
yarn playwright install-deps
```

## Running Tests

### Run All Tests (Headless)

```bash
yarn test:playwright
# or
npm run test:playwright
```

### Run with UI Mode (Interactive)

UI mode provides a visual interface to run and debug tests:

```bash
yarn test:playwright:ui
# or
npm run test:playwright:ui
```

### Run in Headed Mode (See Browser)

```bash
yarn test:playwright:headed
# or
npm run test:playwright:headed
```

### Debug Mode

Step through tests with debugging tools:

```bash
yarn test:playwright:debug
# or
npm run test:playwright:debug
```

### Run Specific Test File

```bash
yarn playwright test language-selector.spec.js
```

### Run Specific Test

```bash
yarn playwright test -g "switching to French"
```

## Test Coverage

### Language Selector Tests

The `language-selector.spec.js` test suite covers:

1. **Initial Page Load**
   - Verifies page loads with English locale by default
   - Checks html `lang` attribute is set to 'en'
   - Validates English search placeholder

2. **Language Switching**
   - Tests switching to French, Spanish, and Portuguese
   - Verifies html `lang` attribute updates correctly
   - Confirms search placeholder is translated
   - Validates active language link styling

3. **Direct Navigation**
   - Tests navigating directly to locale URLs (e.g., `/fr`)
   - Verifies locale is set correctly

4. **Language Selector UI**
   - All language links are present and visible
   - Proper ARIA labels for accessibility

### Search Functionality Regression Tests

These tests ensure that language switching does not break search functionality:

1. **Basic Search Functionality**
   - Search input is visible and enabled
   - Placeholder text is correct for each locale
   - User can type in search field

2. **Cross-Locale Functionality**
   - Search maintains functionality after language switch
   - Search form structure is consistent across all locales
   - Search button is properly translated

## Test Configuration

The test configuration is defined in `playwright.config.js` at the project root:

- **Base URL**: `http://localhost:3000` (configurable via `TEST_BASE_URL` env var)
- **Test Directory**: `./test/playwright`
- **Browser**: Chromium (can be extended to Firefox, Safari, etc.)
- **Web Server**: Automatically starts Rails server in test mode

### Configuration Options

```javascript
// Run tests against a different URL
TEST_BASE_URL=http://staging.example.com yarn test:playwright

// Skip automatic server start
SKIP_SERVER=true yarn test:playwright
```

## Writing New Tests

### Basic Test Structure

```javascript
const { test, expect } = require('@playwright/test');

test.describe('Feature Name', () => {
  test('should do something', async ({ page }) => {
    await page.goto('/');
    
    // Interact with page
    await page.click('button');
    
    // Make assertions
    await expect(page.locator('h1')).toHaveText('Expected Text');
  });
});
```

### Best Practices

1. **Use Descriptive Test Names**: Test names should clearly describe what is being tested
2. **Isolate Tests**: Each test should be independent and not rely on state from other tests
3. **Use Explicit Waits**: Wait for elements to be visible/enabled before interacting
4. **Use Page Object Pattern**: For complex pages, consider using page objects
5. **Test User Flows**: Focus on critical user journeys, not implementation details

### Locators

Playwright provides powerful locators:

```javascript
// By text
page.locator('button:has-text("Submit")')

// By CSS
page.locator('.language-nav__link')

// By test ID (recommended for stable tests)
page.locator('[data-testid="submit-button"]')

// By role (accessible)
page.locator('role=button[name="Submit"]')
```

## CI Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Install Playwright
  run: yarn playwright install --with-deps

- name: Run Playwright tests
  run: yarn test:playwright
```

## Debugging

### Debug Failed Tests

When a test fails:

1. Check the test output for error messages
2. Run the test in headed mode: `yarn test:playwright:headed`
3. Run in debug mode: `yarn test:playwright:debug`
4. Check screenshots/videos in `test-results/` directory

### Visual Debugging

Playwright automatically captures:
- **Screenshots**: On test failure
- **Videos**: Of entire test run (configurable)
- **Traces**: Detailed timeline of test execution

View trace files:

```bash
yarn playwright show-trace test-results/path-to-trace.zip
```

## Comparison with Existing E2E Tests

The project also has Puppeteer-based E2E tests in `test/e2e/`. Key differences:

| Feature | Puppeteer | Playwright |
|---------|-----------|------------|
| Browser Support | Chrome/Chromium | Chrome, Firefox, Safari, Edge |
| API Style | Callback-based | Promise-based with await |
| Test Runner | Custom | Built-in with test isolation |
| Debugging | Basic | Advanced with UI mode |
| Auto-waiting | Manual | Automatic |

Both test suites can coexist. Playwright is recommended for new tests.

## Resources

- [Playwright Documentation](https://playwright.dev/)
- [Playwright API Reference](https://playwright.dev/docs/api/class-playwright)
- [Best Practices](https://playwright.dev/docs/best-practices)
- [Debugging Guide](https://playwright.dev/docs/debug)

## Issue Tracking

This test suite was created to address GitHub Issue #1137:
- Update locale and layout tests to cover new language selector functionality
- Ensure search functionality has no regressions
- Add Playwright test to verify language switching updates I18n.locale and html lang attribute correctly
