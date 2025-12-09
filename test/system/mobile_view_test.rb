# frozen_string_literal: true

require 'application_system_test_case'

class MobileViewTest < ApplicationSystemTestCase
  setup do
    resize_window_to_mobile
  end

  test 'navigation renders the mobile layout at small viewports' do
    visit static_home_path

    mobile_width = page.evaluate_script('window.innerWidth')
    assert_operator mobile_width, :<=, 430, "Expected window width to be mobile-sized, got #{mobile_width}"

    # Desktop nav should be hidden on mobile widths
    desktop_nav_display = page.evaluate_script(<<~JS)
      (() => {
        const nav = document.querySelector('#nav-mobile');
        return nav ? getComputedStyle(nav).display : null;
      })();
    JS
    assert_equal 'none', desktop_nav_display

    # Mobile menu trigger should be visible for mobile navigation
    assert_selector '.sidenav-trigger', visible: true
  end
end
