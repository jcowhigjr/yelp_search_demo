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

  # Resize the current Capybara window to a mobile-friendly viewport
  def resize_window_to_mobile(width: 375, height: 667)
    resized = false

    if page.respond_to?(:current_window) && page.current_window.respond_to?(:resize_to)
      page.current_window.resize_to(width, height)
      resized = true
    elsif page.driver.respond_to?(:resize)
      page.driver.resize(width, height)
      resized = true
    elsif page.driver.respond_to?(:resize_window_to)
      page.driver.resize_window_to(page.driver.current_window_handle, width, height)
      resized = true
    elsif page.driver.respond_to?(:browser)
      browser = page.driver.browser
      if browser.respond_to?(:resize)
        browser.resize(width, height)
        resized = true
      elsif browser.respond_to?(:manage) && browser.manage.respond_to?(:window)
        browser.manage.window.resize_to(width, height)
        resized = true
      end
    end

    raise 'Current Capybara driver does not support window resizing' unless resized

    page.evaluate_script('window.dispatchEvent(new Event("resize"))')
  end
end
