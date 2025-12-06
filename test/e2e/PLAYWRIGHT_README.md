# Playwright E2E Tests

## Overview

This directory contains Playwright-based end-to-end tests for the application. These tests complement the existing Puppeteer tests and provide additional browser automation capabilities.

**Related GitHub Issue:** #1137 (AC5)

## Test Files

### `language-selector-integration.spec.js`

Tests for language selector integration and non-interference with other UI components:

- ✅ Language selector does not interfere with theme toggle
- ✅ Search functionality remains intact across locale changes
- ✅ Theme toggle and search work together after multiple locale switches
- ✅ HTML lang attribute updates correctly without breaking other functionality
- ✅ Locale switching preserves page structure and all interactive elements
- ✅ I18n.locale updates are reflected in translated content

## Prerequisites

- Node.js and npm/yarn installed
- Rails server running on `http://localhost:3000` (or custom URL via `TEST_BASE_URL`)
- Playwright installed via `yarn install`
- Playwright browsers installed: `npx playwright install`

## Installation

```bash
# Install dependencies
yarn install

# Install Playwright browsers (one-time setup)
npx playwright install
```

## Running Tests

### Run all Playwright tests

```bash
# Headless mode (default)
yarn test:playwright

# Headed mode (see browser)
yarn test:playwright:headed

# Interactive UI mode (recommended for development)
yarn test:playwright:ui
```

### Run language selector integration tests only

```bash
yarn test:playwright:integration
```

### Run with custom base URL

```bash
TEST_BASE_URL=http://localhost:5000 yarn test:playwright
```

## Configuration

Playwright configuration is defined in `playwright.config.js` at the project root.

Key settings:
- **testDir**: `./test/e2e`
- **testMatch**: `**/*.spec.js`
- **timeout**: 30 seconds per test
- **baseURL**: `http://localhost:3000` (configurable via `TEST_BASE_URL`)
- **browsers**: Chromium (default)

## Test Structure

Playwright tests use the following structure:

```javascript
const { test, expect } = require('@playwright/test');

test.describe('Test Suite Name', () => {
  test('test name', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('selector')).toBeVisible();
    // ... test assertions
  });
});
```

## Comparison with Puppeteer Tests

| Feature | Puppeteer | Playwright |
|---------|-----------|------------|
| **Location** | `test/e2e/language-switcher.test.js` | `test/e2e/language-selector-integration.spec.js` |
| **Focus** | Basic language switching flow | Integration and non-interference testing |
| **Browser Support** | Chromium | Chromium (configurable for Firefox, WebKit) |
| **Test Runner** | Custom (Node.js) | Built-in Playwright Test |
| **Assertions** | Manual console logging | Built-in expect assertions |
| **Screenshots** | Manual | Automatic on failure |
| **Retries** | None | Configurable (2 on CI) |

## Test Coverage

The Playwright integration tests specifically verify:

1. **Non-interference with Theme Toggle**
   - Theme toggle button remains visible after language switch
   - Theme toggle remains functional after language switch
   - Theme icon changes when toggled

2. **Search Functionality Across Locales**
   - Search input remains visible across locale changes
   - Search placeholder text is correctly translated
   - Search button remains enabled
   - User can type in search input after locale changes

3. **Multiple Locale Switches**
   - All UI elements remain functional after switching between multiple locales
   - Theme toggle and search work together after multiple switches

4. **HTML Lang Attribute Updates**
   - `html[lang]` attribute updates correctly when switching locales
   - Other functionality remains intact after lang attribute changes

5. **Page Structure Preservation**
   - All critical elements remain visible after locale switches
   - Interactive elements remain functional

6. **Translated Content Verification**
   - Search placeholders are correctly translated
   - Active language link has correct styling

## Debugging

### View test execution in browser

```bash
yarn test:playwright:headed
```

### Use Playwright Inspector

```bash
PWDEBUG=1 yarn test:playwright
```

### View test report

```bash
npx playwright show-report
```

### View screenshots on failure

Screenshots are automatically saved to `test-results/` directory when tests fail.

## CI Integration

Playwright tests are configured to:
- Run in headless mode on CI
- Retry failed tests up to 2 times
- Fail the build if `test.only` is accidentally left in code
- Generate test reports

## Adding New Tests

1. Create a new `.spec.js` file in `test/e2e/`
2. Import Playwright test utilities:
   ```javascript
   const { test, expect } = require('@playwright/test');
   ```
3. Write your test using `test.describe()` and `test()` blocks
4. Run tests: `yarn test:playwright`

## Troubleshooting

### Test fails with "Navigation timeout"

- Ensure Rails server is running on the correct port
- Check if `TEST_BASE_URL` is set correctly
- Increase timeout in `playwright.config.js` if needed

### Test fails with "Element not found"

- Run in headed mode to see what's happening: `yarn test:playwright:headed`
- Use Playwright Inspector: `PWDEBUG=1 yarn test:playwright`
- Check if selectors match current HTML structure

### Browser not installed

```bash
npx playwright install chromium
```

## Related Files

- **System Tests**: `test/system/locales_test.rb` (Rails system tests using Capybara/Cuprite)
- **Puppeteer Tests**: `test/e2e/language-switcher.test.js` (existing Puppeteer tests)
- **Configuration**: `playwright.config.js` (Playwright configuration)
- **Views**: `app/views/layouts/_footer.html.erb` (language selector implementation)
- **Locale Files**: `config/locales/*.yml` (translations)

## Best Practices

1. **Use data attributes for selectors** when possible (e.g., `data-testid="element"`)
2. **Wait for navigation** after clicking links: `await page.waitForLoadState('networkidle')`
3. **Use built-in assertions** instead of manual checks: `await expect(locator).toBeVisible()`
4. **Test user workflows** rather than implementation details
5. **Keep tests independent** - each test should run in isolation
6. **Clean up state** - tests should not depend on previous test state

## References

- [Playwright Documentation](https://playwright.dev/)
- [Playwright Test API](https://playwright.dev/docs/api/class-test)
- [Best Practices](https://playwright.dev/docs/best-practices)
- [Rails System Testing Guide](https://guides.rubyonrails.org/testing.html#system-testing)
