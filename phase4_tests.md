## Phase 4: Add tests for language selector

### Problem

The language selector needs comprehensive test coverage to ensure functionality works correctly across different scenarios and prevent regressions.

### Acceptance Criteria

1. **System test coverage**
   - Test language selector visibility and basic functionality
   - Test language switching updates locale and page correctly
   - Test current locale is highlighted in dropdown
   - Test language selector works on different pages

2. **Accessibility testing**
   - Test keyboard navigation works (Tab, Enter, Space, Arrow keys, Escape)
   - Test ARIA attributes are present and correct
   - Test screen reader compatibility
   - Test focus management

3. **Mobile/responsive testing**
   - Test tap targets are 44x44px minimum
   - Test dropdown alignment on narrow viewports
   - Test touch interactions work correctly

### Test Implementation

#### System Test File: `test/system/language_selector_test.rb`
```ruby
require "test_helper"

class LanguageSelectorTest < ApplicationSystemTestCase
  test "language selector is visible in navbar" do
    visit root_path
    assert_selector ".language-selector", visible: true
    assert_selector ".language-toggle", visible: true
    assert_text I18n.locale.upcase, count: 1
  end

  test "language dropdown opens and closes" do
    visit root_path
    toggle = find(".language-toggle")
    
    # Open dropdown
    toggle.click
    assert_selector ".language-dropdown", visible: true
    assert_selector ".language-dropdown[hidden]", count: 0
    assert_toggle_expanded(true)
    
    # Close by clicking outside
    find("body").click
    assert_selector ".language-dropdown[hidden]", visible: false
    assert_toggle_expanded(false)
  end

  test "language switching works correctly" do
    visit root_path
    
    # Switch to French
    toggle_language_dropdown
    click_link "Français"
    
    # Verify locale changed
    assert_current_path "/fr"
    assert_equal "fr", I18n.locale.to_s
    assert_selector "html[lang='fr']"
    
    # Verify language selector updated
    assert_text "FR", count: 1
  end

  test "current locale is highlighted in dropdown" do
    visit "/fr"
    
    toggle_language_dropdown
    
    # French should be active
    french_link = find_link("Français")
    assert french_link[:class].include?("active")
    
    # Other languages should not be active
    english_link = find_link("English")
    refute english_link[:class].include?("active")
  end

  test "language switching preserves query parameters" do
    visit new_search_path(query: "coffee")
    
    toggle_language_dropdown
    click_link "Français"
    
    # Query parameters should be preserved
    assert_current_path "/fr/searches/new?query=coffee"
  end

  test "keyboard navigation works" do
    visit root_path
    toggle = find(".language-toggle")
    
    # Focus toggle and open with Enter
    toggle.focus
    toggle.send_keys(:enter)
    assert_selector ".language-dropdown", visible: true
    
    # Navigate with arrow keys
    send_keys(:arrow_down)
    assert focused_link_matches?("English")
    
    send_keys(:arrow_down)
    assert focused_link_matches?("Français")
    
    # Select with Enter
    send_keys(:enter)
    assert_current_path "/fr"
  end

  test "escape closes dropdown and returns focus" do
    visit root_path
    toggle = find(".language-toggle")
    
    toggle.click
    send_keys(:escape)
    
    assert_selector ".language-dropdown[hidden]", visible: false
    assert_equal toggle, page.active_element
  end

  test "mobile responsive behavior" do
    using_window_size(375, 667) do # iPhone size
      visit root_path
      
      # Tap target should be large enough
      toggle = find(".language-toggle")
      assert toggle.native.size.height >= 44
      assert toggle.native.size.width >= 44
      
      # Dropdown should not overflow viewport
      toggle.click
      dropdown = find(".language-dropdown")
      dropdown_rect = dropdown.native.rect
      
      assert dropdown_rect.x >= 0
      assert dropdown_rect.x + dropdown_rect.width <= 375
    end
  end

  test "accessibility attributes are present" do
    visit root_path
    toggle = find(".language-toggle")
    
    # Check ARIA attributes
    assert_equal "true", toggle[:'aria-haspopup']
    assert_equal "false", toggle[:'aria-expanded']
    
    # Open dropdown and check menu attributes
    toggle.click
    dropdown = find(".language-dropdown")
    assert_equal "menu", dropdown[:role]
  end

  private

  def toggle_language_dropdown
    find(".language-toggle").click
  end

  def assert_toggle_expanded(expanded)
    toggle = find(".language-toggle")
    assert_equal expanded.to_s, toggle[:'aria-expanded']
  end

  def focused_link_matches?(text)
    page.active_element.text.strip == text
  end

  def send_keys(*keys)
    page.active_element.send_keys(*keys)
  end
end
```

#### Integration Test: `test/integration/language_switching_test.rb`
```ruby
require "test_helper"

class LanguageSwitchingTest < ActionDispatch::IntegrationTest
  test "locale parameter updates I18n.locale" do
    get root_path(locale: 'fr')
    assert_equal 'fr', I18n.locale.to_s
  end

  test "html lang attribute matches current locale" do
    get root_path(locale: 'es')
    assert_select "html[lang='es']"
  end

  test "invalid locale falls back to default" do
    get root_path(locale: 'invalid')
    assert_equal 'en', I18n.locale.to_s
  end

  test "locale persists in session" do
    get root_path(locale: 'fr')
    follow_redirect!
    
    get new_search_path
    assert_equal 'fr', I18n.locale.to_s
  end
end
```

### Files to Create

- `test/system/language_selector_test.rb` - System tests for UI behavior
- `test/integration/language_switching_test.rb` - Integration tests for locale handling

### Definition of Done

- [ ] All system tests pass
- [ ] Integration tests cover locale routing
- [ ] Mobile responsive tests pass
- [ ] Accessibility tests pass
- [ ] No regressions in existing tests
- [ ] Tests cover edge cases (invalid locales, etc.)

### Risk Level: LOW
- Pure test additions
- No production code changes
- Easy to verify and maintain

### Estimated Effort: 3-4 hours
- System test implementation: 2 hours
- Integration tests: 1 hour
- Mobile/responsive testing: 1 hour

### Dependencies

- **Requires**: Phase 1 (#1173), Phase 2 (#1174), Phase 3 (#1175) - Full language selector implementation
- **No prerequisites for**: This is the final phase

### GitHub Relationships

**Blocked by:** #1173, #1174, #1175

### Deployment Order

**Must be deployed last** - This phase adds comprehensive tests for the completed language selector functionality from Phases 1-3.
- Test environment should be set up for system tests

### Success Metrics

- 100% test coverage for language selector functionality
- Tests catch regressions before deployment
- Confidence in language switching across browsers
- Documentation of expected behavior through tests
