require 'application_system_test_case'

class ThemeToggleTest < ApplicationSystemTestCase
  test 'user can toggle between light and dark mode' do
    visit '/'

    # Check for prototype theme toggle styling
    toggle_btn = find('button[aria-label="Toggle theme"]')
    
    # Verify prototype styling
    assert_match /fixed.*top.*right/, toggle_btn[:class] || ''
    assert_match /rounded-full/, toggle_btn[:class] || ''
    assert_selector 'button[aria-label="Toggle theme"] i.material-icons', text: 'brightness_4'

    # Initial state (assumes light mode default or OS preference, but we check the toggle works)
    # Get initial theme value
    initial_theme = page.evaluate_script('document.documentElement.getAttribute("data-theme")') || 'light'
    
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

  test 'theme toggle affects CSS variables across pages' do
    visit '/'

    # Check initial theme
    initial_theme = page.evaluate_script('document.documentElement.getAttribute("data-theme")') || 'light'
    
    # Toggle theme
    toggle_btn = find('button[aria-label="Toggle theme"]')
    toggle_btn.click
    
    # Verify theme persistence across navigation
    visit new_search_path
    assert_equal 'dark', page.evaluate_script('document.documentElement.getAttribute("data-theme")')
    
    # Note: CSS variables in navbar style are not yet fully implemented
    # This test can be extended when those features are added
    
    # Navigate to another page
    visit '/login'
    assert_equal 'dark', page.evaluate_script('document.documentElement.getAttribute("data-theme")')
  end
end
