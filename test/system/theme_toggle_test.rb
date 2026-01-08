require 'application_system_test_case'

class ThemeToggleTest < ApplicationSystemTestCase
  test 'user can toggle between light and dark mode' do
    visit '/'

    # Initial state (assumes light mode default or OS preference, but we check the toggle works)
    # Get initial theme value
    initial_theme = page.evaluate_script('document.documentElement.getAttribute("data-theme")') || 'light'
    
    # Find toggle button
    toggle_btn = find('button[aria-label="Toggle theme"]')
    
    # Click toggle
    toggle_btn.click
    
    # Verify theme changed
    expected_theme = initial_theme == 'dark' ? 'light' : 'dark'

    assert_equal expected_theme, page.evaluate_script('document.documentElement.getAttribute("data-theme")')
    
    # Verify persistence
    assert_equal expected_theme, page.evaluate_script('localStorage.getItem("theme")')
    
    # Click again
    toggle_btn.click
    
    # Verify it toggles back
    assert_equal initial_theme, page.evaluate_script('document.documentElement.getAttribute("data-theme")')
  end
end
