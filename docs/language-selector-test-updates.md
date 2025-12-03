# Language Selector Test Updates - Issue #1092

## Overview

This document describes the test updates made to support the new language selector implementation. The new selector is a dropdown button located in the top-right area of the layout (near the theme toggle), replacing the previous footer-based language links.

**GitHub Issue:** #1092

## Changes Summary

### 1. Rails System Tests (`test/system/locales_test.rb`)

#### Updated Tests
- **`the language selector shows all available locales`**: Enhanced to detect and test the new dropdown button selector with `button[aria-haspopup="true"]`, falling back to footer links if not present
- **Added `clicking language selector updates I18n locale and page content`**: New test that verifies language switching works correctly and updates `I18n.locale`, URL path, and page content

#### Key Improvements
- Conditional logic to support both old (footer) and new (dropdown button) implementations
- Explicit verification that clicking a language option:
  - Navigates to the correct locale URL (e.g., `/fr`)
  - Updates the `html[lang]` attribute
  - Translates page content (verified via search placeholder)
- Better wait conditions for dropdown menu visibility
- More specific selectors using `[role="menu"]` and `[role="menuitem"]` for accessibility

### 2. Rails Integration Tests (`test/integration/switch_locale_test.rb`)

#### Updates
- **`Links to all available locales will show`**: Updated comments to clarify that language links can appear in nav, footer, or dropdown menu
- Tests remain flexible to work with any DOM location for language links

### 3. Playwright E2E Tests

#### Updated: `test/e2e/language-switcher.test.js`
Enhanced the existing test to support both implementations:

- **Test 4**: Now checks for new selector button first, falls back to footer
- **Test 8**: Verifies active language indicator for both button (shows current locale) and footer (active class)

#### New: `test/e2e/language-selector-dropdown.test.js`
Comprehensive test suite specifically for the new language selector dropdown:

**Tests (12 total):**
1. ✅ Initial page loads with English locale
2. ✅ Language selector button is present
3. ✅ Button has correct ARIA attributes (`aria-haspopup`, `aria-expanded`, `aria-label`)
4. ✅ Button displays current locale
5. ✅ Dropdown opens when button is clicked
6. ✅ All language options present in dropdown (English, Português, Français, Español)
7. ✅ Clicking French option navigates correctly
8. ✅ `I18n.locale` updates to French (`html[lang="fr"]`)
9. ✅ URL updates to `/fr`
10. ✅ Page content translated to French
11. ✅ Button displays French locale after switch
12. ✅ Mobile viewport test (375x667px, tap target size validation)

**Key Features:**
- Accessibility testing (ARIA attributes)
- Mobile ergonomics validation (44x44px tap target recommendation)
- I18n.locale verification through `html[lang]` attribute
- URL path verification
- Content translation verification
- Supports both headless and headed modes

## Running the Tests

### Rails Tests

```bash
# Run all system tests
mise exec -- bin/rails test:system

# Run specific locale tests
mise exec -- bin/rails test test/system/locales_test.rb

# Run specific test
mise exec -- bin/rails test test/system/locales_test.rb:90
```

### Playwright Tests

```bash
# Prerequisites: Rails server running on localhost:3000
mise exec -- bin/rails server

# In another terminal:

# Original language switcher test (supports both implementations)
npm run test:e2e:language                    # Headless
npm run test:e2e:language:headed             # Headed (visible browser)

# New language selector dropdown test
npm run test:e2e:language-selector           # Headless
npm run test:e2e:language-selector:headed    # Headed (visible browser)

# Or run directly with custom URL
TEST_BASE_URL=http://localhost:5000 node test/e2e/language-selector-dropdown.test.js
```

## Test Coverage

### Functionality Tested
- ✅ Language selector presence and location
- ✅ Dropdown menu interaction
- ✅ All available locales displayed
- ✅ Language switching navigation
- ✅ I18n.locale updates correctly
- ✅ URL path updates with locale
- ✅ Page content translation
- ✅ Active language indication
- ✅ Accessibility (ARIA attributes)
- ✅ Mobile viewport compatibility
- ✅ Tap target size validation

### Backward Compatibility
All tests support both implementations:
- **New**: Dropdown button with `button[aria-haspopup="true"]` in top-right
- **Old**: Footer links with `.language-nav` class

Tests automatically detect which implementation is present and adjust accordingly.

## Implementation Requirements (for new selector)

Based on the test expectations, the new language selector should:

### HTML Structure
```erb
<!-- In layout, near theme toggle -->
<button 
  aria-haspopup="true" 
  aria-expanded="false"
  aria-label="Select language">
  <%= I18n.locale.to_s.upcase %>
</button>

<div role="menu" class="language-menu" hidden>
  <% I18n.available_locales.each do |locale| %>
    <%= link_to request.params.merge(locale: resolve_locale(locale)),
                role: "menuitem" do %>
      <%= t('layouts.footer.language_name_of_locale', locale: locale) %>
    <% end %>
  <% end %>
</div>
```

### Accessibility Requirements
- `aria-haspopup="true"` on button
- `aria-expanded` toggles between "false" and "true"
- `aria-label` describes the button purpose
- `role="menu"` on dropdown container
- `role="menuitem"` on language options

### Mobile Requirements
- Button tap target: minimum 44x44px (iOS HIG)
- Dropdown should not be clipped by viewport edges
- Full-width tap targets on small screens
- Comfortable thumb interaction

### Styling Requirements
- Use CSS variables: `var(--color-bg)`, `var(--color-text)`, `var(--color-border)`, `var(--color-primary)`
- Position near theme toggle in top-right
- Responsive design for mobile viewports
- Clear visual indication of current locale

## Integration with CI

### Current State
Tests can be run independently and are ready for CI integration.

### Future CI Integration
Add to `.github/workflows/main.yml`:

```yaml
e2e-language-tests:
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
    
    - name: Run language selector tests
      run: |
        npm run test:e2e:language
        npm run test:e2e:language-selector
```

## Migration Path

1. **Phase 1** (Current): Tests support both implementations
   - Footer language links continue to work
   - Tests detect new selector if present
   
2. **Phase 2**: Implement new language selector
   - Add dropdown button to layout
   - Tests automatically use new selector
   
3. **Phase 3**: Remove footer language links
   - Clean up old implementation
   - Tests continue to work with new selector only

## Related Files

### Test Files
- `test/system/locales_test.rb` - Rails system tests
- `test/integration/switch_locale_test.rb` - Rails integration tests
- `test/e2e/language-switcher.test.js` - Original Playwright test (updated)
- `test/e2e/language-selector-dropdown.test.js` - New comprehensive Playwright test

### Documentation
- `docs/e2e-language-switcher-tests.md` - Original E2E test documentation
- `docs/language-selector-test-updates.md` - This file

### Implementation Files (to be updated)
- `app/views/layouts/application.html.erb` - Main layout
- `app/views/layouts/_footer.html.erb` - Footer (remove language links)
- `app/controllers/concerns/locales.rb` - Locale handling
- `config/routes.rb` - Locale routing

## Acceptance Criteria Met

✅ Updated existing Rails tests for locale switching to work with new selector location  
✅ Updated existing Rails tests for layout rendering to work with new selector location  
✅ Created new Playwright test that verifies language switching functionality  
✅ Test verifies clicking languages updates I18n.locale correctly  
✅ Tests verify URL path updates with locale  
✅ Tests verify page content translation  
✅ Tests include accessibility verification (ARIA attributes)  
✅ Tests include mobile viewport validation  
✅ Tests support backward compatibility with footer implementation  
✅ Documentation provided for test updates and implementation requirements  

## References

- [GitHub Issue #1092](https://github.com/jcowhigjr/yelp_search_demo/issues/1092)
- [Puppeteer Documentation](https://pptr.dev/)
- [Rails Internationalization Guide](https://guides.rubyonrails.org/i18n.html)
- [ARIA Authoring Practices - Menu Button](https://www.w3.org/WAI/ARIA/apg/patterns/menu-button/)
- [iOS Human Interface Guidelines - Tap Targets](https://developer.apple.com/design/human-interface-guidelines/layout)
