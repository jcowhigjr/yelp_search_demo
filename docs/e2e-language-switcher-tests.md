# Language Switcher E2E Tests - Implementation

## Overview

This document describes the implementation of end-to-end (E2E) tests for the language switcher functionality using Puppeteer. These tests verify that users can successfully switch between different language locales on the homepage.

**GitHub Issue:** #1096

## Implementation Details

### Files Created

1. **`test/e2e/language-switcher.test.js`**
   - Main Puppeteer test file
   - Tests language switching from English to French
   - Validates HTML lang attributes, headings, and placeholders
   - Executable: `chmod +x`

2. **`test/e2e/README.md`**
   - Documentation for running E2E tests
   - Troubleshooting guide
   - Instructions for adding new tests

3. **Documentation (this file)**
   - Implementation summary and rationale

### Files Modified

1. **`package.json`**
   - Added `test:e2e:language` script for running tests in headless mode
   - Added `test:e2e:language:headed` script for running tests with visible browser

## Test Coverage

The language switcher test (`language-switcher.test.js`) verifies the following:

### English (Initial State)
1. ✅ Page loads with `html[lang="en"]`
2. ✅ English heading is present: "Save time by sharing your device location"
3. ✅ English search placeholder: "Search for coffee shops..."

### French (After Language Switch)
4. ✅ French language selector link exists in footer
5. ✅ Language selector can be clicked
6. ✅ Page updates to `html[lang="fr"]` after switching
7. ✅ Heading element still exists (with note if hardcoded)
8. ✅ French search placeholder: "Rechercher des cafés..."
9. ✅ Active language link has `language-nav__link--active` class

## Running the Tests

### Prerequisites

- Rails server must be running on `http://localhost:3000` (or specify custom URL)
- Puppeteer is already installed as a devDependency

### Commands

**Run in headless mode (recommended for CI):**
```bash
npm run test:e2e:language
# or
yarn test:e2e:language
```

**Run in headed mode (see browser for debugging):**
```bash
npm run test:e2e:language:headed
# or
yarn test:e2e:language:headed
```

**Run with custom URL:**
```bash
TEST_BASE_URL=http://localhost:5000 node test/e2e/language-switcher.test.js
```

### Environment Variables

- `TEST_BASE_URL` - Base URL for the application (default: `http://localhost:3000`)
- `TEST_HEADLESS` - Run browser in headless mode (default: `true`)

## Technical Implementation Notes

### Language Detection

The test uses Puppeteer's page evaluation to extract the `lang` attribute from the HTML element:

```javascript
async function getHtmlLang(page) {
  return await page.evaluate(() => {
    return document.documentElement.getAttribute('lang');
  });
}
```

### Navigation Handling

The test waits for navigation to complete after clicking the language selector:

```javascript
await page.waitForNavigation({ waitUntil: 'networkidle0', timeout: TIMEOUT });
```

### Selector Strategy

Language links are found using a combination of:
1. Footer navigation container: `footer .language-nav`
2. Text content matching: `textContent.trim() === 'Français'`

This approach is resilient to changes in the HTML structure.

### Hardcoded Content Handling

The test is aware that some content (like the main heading) may be hardcoded and not translated. It validates:
- The locale attribute changes correctly
- The search placeholder is properly translated (uses i18n)
- The heading element exists, with a warning if it's still in English

## Translation Coverage

Based on `config/locales/`:

| Element | English | French |
|---------|---------|--------|
| HTML lang | `en` | `fr` |
| Search placeholder | "Search for coffee shops..." | "Rechercher des cafés..." |
| Language link text | "English" | "Français" |

**Note:** The main heading "Save time by sharing your device location" is currently hardcoded in `app/views/static/home.html.erb` and does not change with locale. This is a known limitation documented in the test.

## Integration with CI

### Current State

The tests are standalone and can be run independently. They are not yet integrated into the main CI workflow (`.github/workflows/main.yml`).

### Future Integration

To add these tests to CI:

1. Add a new job to `.github/workflows/main.yml`:
   ```yaml
   e2e-tests:
     runs-on: ubuntu-latest
     steps:
       - name: Checkout code
         uses: actions/checkout@v6
       
       - name: Setup Node.js
         uses: actions/setup-node@v4
         with:
           node-version: '20'
       
       - name: Install dependencies
         run: npm install
       
       - name: Start Rails server
         run: |
           mise exec -- bin/rails server -e test -p 3000 &
           sleep 5
       
       - name: Run E2E Language Tests
         run: npm run test:e2e:language
   ```

2. Consider using a test matrix for multiple locales:
   - English → French
   - English → Spanish
   - English → Portuguese

## Testing Philosophy

These tests follow the "user journey" testing pattern:
1. Start from a known state (English homepage)
2. Perform user actions (click language selector)
3. Verify expected outcomes (locale changes, content updates)

This approach ensures that the language switching functionality works from the user's perspective, not just at the unit level.

## Troubleshooting

### Common Issues

**Test fails with "Navigation timeout":**
- Ensure Rails server is running
- Check if port 3000 is available
- Increase TIMEOUT constant if needed

**Test fails with "Element not found":**
- Page structure may have changed
- Run in headed mode to debug: `npm run test:e2e:language:headed`
- Check selectors match current HTML

**Test passes locally but fails in CI:**
- Ensure CI environment has Chromium/Chrome
- Check that fonts and assets are loaded
- Add longer wait times for CI (slower environment)

## Future Enhancements

1. **Add more locale tests**
   - Spanish (es)
   - Portuguese (pt-BR)
   - Thai (th)

2. **Test additional translated content**
   - Navigation menu items
   - Button labels
   - Error messages

3. **Add visual regression tests**
   - Compare screenshots across locales
   - Verify text direction for RTL languages

4. **Test persistence**
   - Verify locale persists across page navigation
   - Test cookie/session storage

## Related Files

- **Views:** `app/views/layouts/application.html.erb` (lang attribute)
- **Footer:** `app/views/layouts/_footer.html.erb` (language selector)
- **Locale files:** `config/locales/*.yml`
- **System tests:** `test/system/locales_test.rb` (Rails system tests)
- **Integration tests:** `test/integration/switch_locale_test.rb`

## Acceptance Criteria Met

✅ Created Puppeteer test file that navigates to homepage  
✅ Verified initial page loads with `html[lang="en"]`  
✅ Verified English headings are present  
✅ Implemented test logic to locate language selector  
✅ Implemented interaction with language selector to switch to French  
✅ Added assertions to verify page updates to `html[lang="fr"]`  
✅ Added assertions to verify French content is displayed  
✅ Tests are executable and documented  

## References

- [Puppeteer Documentation](https://pptr.dev/)
- [Rails Internationalization Guide](https://guides.rubyonrails.org/i18n.html)
- Existing visual verification script: `scripts/visual-verification.js`
- Existing Rails system tests: `test/system/locales_test.rb`
