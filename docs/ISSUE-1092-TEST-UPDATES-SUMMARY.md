# Issue #1092: Test Updates Summary

## Task Completed
Updated existing Rails tests for locale switching and layout rendering to work with the new language selector location. Created a new Playwright test that verifies language switching functionality works correctly and tests that clicking languages updates I18n.

## Files Modified

### 1. `test/system/locales_test.rb`
**Changes:**
- Enhanced `the language selector shows all available locales` test to detect and support the new dropdown button selector with `button[aria-haspopup="true"]`
- Added fallback to footer links for backward compatibility
- Added new test `clicking language selector updates I18n locale and page content` that:
  - Verifies initial locale is English
  - Tests both new dropdown button and old footer link implementations
  - Confirms clicking French option navigates to `/fr`
  - Verifies `html[lang]` attribute updates
  - Confirms page content is translated (via search placeholder)

### 2. `test/integration/switch_locale_test.rb`
**Changes:**
- Updated comments in `Links to all available locales will show` test to clarify that language links can appear in nav, footer, or dropdown menu
- Tests remain flexible to work with any DOM location

### 3. `test/e2e/language-switcher.test.js`
**Changes:**
- Updated Test 4 to check for new selector button first, then fall back to footer
- Enhanced logic to handle dropdown interaction (clicking button, waiting for menu, selecting option)
- Updated Test 8 to verify active language indicator for both implementations:
  - New: Button shows current locale code
  - Old: Footer link has active class

### 4. `test/e2e/language-selector-dropdown.test.js` (NEW)
**Created comprehensive new test suite with 12 tests:**
1. Initial page loads with English locale
2. Language selector button is present
3. Button has correct ARIA attributes
4. Button displays current locale
5. Dropdown opens when clicked
6. All language options present in dropdown
7. Clicking French option navigates correctly
8. I18n.locale updates to French
9. URL updates to /fr
10. Page content translated to French
11. Button displays French locale after switch
12. Mobile viewport test with tap target validation

### 5. `package.json`
**Changes:**
- Added `test:e2e:language-selector` script for new test (headless mode)
- Added `test:e2e:language-selector:headed` script for headed mode

### 6. `docs/language-selector-test-updates.md` (NEW)
**Created comprehensive documentation including:**
- Overview of changes
- Detailed test descriptions
- Running instructions
- Test coverage details
- Implementation requirements
- CI integration guidance
- Migration path
- References

### 7. `docs/ISSUE-1092-TEST-UPDATES-SUMMARY.md` (NEW)
**This file** - Summary of all changes made

## Test Strategy

### Backward Compatibility
All tests support both implementations:
- **New**: Dropdown button with `button[aria-haspopup="true"]` in top-right layout area
- **Old**: Footer links with `.language-nav` class

Tests automatically detect which implementation is present and adjust behavior accordingly.

### Key Test Coverage
✅ Language selector presence and location  
✅ Dropdown menu interaction  
✅ All available locales displayed  
✅ Language switching navigation  
✅ I18n.locale updates correctly  
✅ URL path updates with locale  
✅ Page content translation  
✅ Active language indication  
✅ Accessibility (ARIA attributes)  
✅ Mobile viewport compatibility  
✅ Tap target size validation (44x44px minimum)  

## Running the Tests

### Rails Tests
```bash
# Run specific locale system tests
mise exec -- bin/rails test test/system/locales_test.rb

# Run specific test
mise exec -- bin/rails test test/system/locales_test.rb:90
```

### Playwright Tests
```bash
# Start Rails server first
mise exec -- bin/rails server

# In another terminal:
# Original test (updated for both implementations)
npm run test:e2e:language

# New comprehensive test
npm run test:e2e:language-selector

# Headed mode for debugging
npm run test:e2e:language-selector:headed
```

## Implementation Readiness

These tests are ready to work with the new language selector implementation once it's built. The implementation should include:

### Required HTML Structure
```erb
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
- `aria-label` describes button purpose
- `role="menu"` on dropdown container
- `role="menuitem"` on language options

### Mobile Requirements
- Button tap target: minimum 44x44px
- Dropdown not clipped by viewport edges
- Full-width tap targets on small screens

### Styling Requirements
- CSS variables: `var(--color-bg)`, `var(--color-text)`, `var(--color-border)`, `var(--color-primary)`
- Position near theme toggle in top-right
- Responsive design for mobile

## Next Steps

1. **Implement the new language selector** in `app/views/layouts/application.html.erb`
2. **Add JavaScript** for dropdown interaction (toggle aria-expanded, show/hide menu)
3. **Add CSS** for styling the button and dropdown
4. **Remove footer language links** from `app/views/layouts/_footer.html.erb`
5. **Run tests** to verify implementation
6. **Adjust tests** if needed based on actual implementation details

## Validation

All modified and new files have been validated:
- ✅ Ruby syntax checks passed
- ✅ JavaScript syntax checks passed
- ✅ JSON validation passed
- ✅ File permissions set correctly (executable for .js tests)

## Success Criteria Met

✅ Updated existing Rails tests for locale switching  
✅ Updated existing Rails tests for layout rendering  
✅ Created new Playwright test for language switching  
✅ Tests verify I18n.locale updates correctly  
✅ Tests verify URL path updates  
✅ Tests verify page content translation  
✅ Tests include accessibility verification  
✅ Tests include mobile viewport validation  
✅ Tests support backward compatibility  
✅ Comprehensive documentation provided  

## References

- GitHub Issue: #1092
- Documentation: `docs/language-selector-test-updates.md`
- Original E2E docs: `docs/e2e-language-switcher-tests.md`
