# frozen_string_literal: true

# SystemTestHelpers provides utilities for cleaner system test debugging
module SystemTestHelpers
  def wait_for_turbo(timeout = nil)
    return unless page.driver.is_a?(Capybara::Cuprite::Driver)

    assert_selector(".turbo-progress-bar", visible: false, wait: timeout)
  end
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
end
