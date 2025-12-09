# frozen_string_literal: true

# SystemTestHelpers provides utilities for cleaner system test debugging
module SystemTestHelpers
  # Print debug information only when explicitly requested via ENV variable
  def debug_output(message)
    puts message if ENV['SYSTEM_TEST_DEBUG'] == 'true'
  end

  # Print page HTML only when debugging is enabled
  def debug_page_html
    return unless ENV['SYSTEM_TEST_DEBUG'] == 'true'
    
    puts "=== PAGE HTML ==="
    puts page.html
    puts "=== END HTML ==="
  end

  # More focused debugging - just print element counts and basic info
  def debug_elements(selector, description = nil)
    elements = all(selector)
    name = description || selector
    puts "Found #{elements.count} #{name}" unless ENV['CI'] == 'true'
  end

  # Silent wait helper that doesn't output noise
  def silent_wait(seconds = 1)
    sleep seconds
  end

  # Resize viewport to a mobile-friendly size so responsive layouts render correctly
  def resize_to_mobile_viewport(width: 375, height: 667)
    if page.driver.respond_to?(:resize_window_to)
      handle = page.driver.respond_to?(:current_window_handle) ? page.driver.current_window_handle : nil
      page.driver.resize_window_to(handle, width, height)
    elsif page.driver.respond_to?(:browser) && page.driver.browser.respond_to?(:manage)
      page.driver.browser.manage.window.resize_to(width, height)
    elsif page.driver.respond_to?(:browser) && page.driver.browser.respond_to?(:resize)
      page.driver.browser.resize(width, height)
    elsif page.driver.respond_to?(:resize)
      page.driver.resize(width, height)
    elsif page.respond_to?(:current_window)
      page.current_window.resize_to(width, height)
    end
  end
end
