# E2E Tests

This directory contains end-to-end tests using Puppeteer for browser automation.

## Prerequisites

- Node.js and npm/yarn installed
- Puppeteer installed (already in devDependencies)
- Rails server running on `http://localhost:3000` (or specify custom URL)

## Running Tests

### Language Switcher Test

Tests the language switching functionality on the homepage.

**Run in headless mode (default):**
```bash
npm run test:e2e:language
# or
yarn test:e2e:language
```

**Run in headed mode (see browser):**
```bash
npm run test:e2e:language:headed
# or
yarn test:e2e:language:headed
```

**Run directly with custom URL:**
```bash
TEST_BASE_URL=http://localhost:5000 node test/e2e/language-switcher.test.js
```

### Environment Variables

- `TEST_BASE_URL` - Base URL for the application (default: `http://localhost:3000`)
- `TEST_HEADLESS` - Run browser in headless mode (default: `true`, set to `false` to see browser)

## Test Coverage

### language-switcher.test.js

This test verifies the language switching functionality with support for both the old footer links and new compact selector:

1. ✅ Initial page loads with `html[lang="en"]`
2. ✅ English heading is present ("Save time by sharing your device location")
3. ✅ English search placeholder is correct ("Search for coffee shops...")
4. ✅ French language selector exists (footer links or top-right dropdown)
5. ✅ Language selector can be clicked
6. ✅ Page updates to `html[lang="fr"]` after switching
7. ✅ French heading is displayed
8. ✅ French search placeholder is correct ("Rechercher des cafés...")
9. ✅ Active language indicator shows current locale

### language-selector-headless.test.js

This test specifically verifies the new compact language selector implementation:

1. ✅ Language selector button exists in top-right near theme toggle
2. ✅ Button has proper accessibility attributes (aria-haspopup, aria-expanded)
3. ✅ Button shows current locale code (e.g., "en")
4. ✅ Dropdown contains all available locales (English, Português, Français, Español)
5. ✅ Clicking French navigates to /fr route
6. ✅ HTML lang attribute updates to "fr"
7. ✅ Button updates to show "fr" after language switch
8. ✅ Button meets mobile tap target size (≥44x44px)
9. ✅ Dropdown items have adequate mobile tap targets (≥44px height)
10. ✅ Dropdown is not clipped by viewport edges on mobile

**Run the new selector test:**
```bash
node test/e2e/language-selector-headless.test.js
# or with custom URL
TEST_BASE_URL=http://localhost:5000 node test/e2e/language-selector-headless.test.js
```

## Adding New Tests

When creating new Puppeteer tests:

1. Create a new file in this directory: `test/e2e/your-test-name.test.js`
2. Make it executable: `chmod +x test/e2e/your-test-name.test.js`
3. Add a npm script in `package.json`:
   ```json
   "test:e2e:your-test": "node test/e2e/your-test-name.test.js"
   ```
4. Follow the existing test structure for consistency

## Troubleshooting

**Test fails with "Navigation timeout":**
- Ensure the Rails server is running
- Check if the correct URL is being used
- Increase the `TIMEOUT` constant in the test file

**Test fails with "Element not found":**
- The page structure may have changed
- Check the selectors in the test file match the current HTML
- Run in headed mode to see what's happening

**Test passes locally but fails in CI:**
- Ensure proper wait times for network requests
- Check that all required fonts/assets are loaded
- Verify the CI environment has proper browser support
