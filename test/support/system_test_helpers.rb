# frozen_string_literal: true

# SystemTestHelpers provides utilities for cleaner system test debugging
module SystemTestHelpers
  MOBILE_BREAKPOINTS = {
    small_phone: { width: 375, height: 667 },
    large_phone: { width: 414, height: 896 },
  }.freeze

  def self.mobile_breakpoints
    MOBILE_BREAKPOINTS
  end

  def self.mobile_screen_size(name = :small_phone)
    breakpoint = MOBILE_BREAKPOINTS.fetch(name)
    [breakpoint[:width], breakpoint[:height]]
  end

  def self.mobile_window_size(name = :small_phone)
    breakpoint = MOBILE_BREAKPOINTS.fetch(name)
    "#{breakpoint[:width]},#{breakpoint[:height]}"
  end

  def mobile_breakpoints
    SystemTestHelpers.mobile_breakpoints
  end

  def mobile_screen_size(name = :small_phone)
    SystemTestHelpers.mobile_screen_size(name)
  end

  def mobile_window_size(name = :small_phone)
    SystemTestHelpers.mobile_window_size(name)
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
