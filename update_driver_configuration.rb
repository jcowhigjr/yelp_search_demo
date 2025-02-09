require 'fileutils'

file_path = '/a0/work_dir/jitter/test/application_system_test_case.rb'

new_content = <<-RUBY
require 'test_helper'
require 'capybara'
require 'capybara/cuprite'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  if ENV.fetch('SELENIUM', nil) == 'true'
    driven_by :selenium,
              using: (ENV['SHOW_TESTS'] ? :chrome : :headless_chrome),
              screen_size: [1400, 1400] do |driver_option|
      driver_option.add_argument('--user-data-dir=/tmp/selenium_user_data')
      driver_option.add_argument('--headless')
      driver_option.add_argument('--disable-gpu')
      driver_option.add_argument('--no-sandbox')
    end
  else
    driven_by :cuprite,
              screen_size: [375, 667],
              options: {
                inspector: !ENV['HEADLESS'].in?(%w[n 0 no false]) && !ENV['MAGIC_TEST'].in?(%w[1]),
                headless: !ENV['HEADLESS'].in?(%w[n 0 no false]) && !ENV['MAGIC_TEST'].in?(%w[1]),
                js_errors: ENV.fetch('CUPRITE_JS_ERRORS', nil) == 'true',
                timeout: 30,
                process_timeout: 30,
                browser_options: {
                  'no-sandbox': true,
                  'disable-web-security': true,
                  'auto-open-devtools-for-tabs': false,
                  'disable-popup-blocking': true,
                  'disable-notifications': true,
                  'use-fake-device-for-media-stream': true,
                  'use-fake-ui-for-media-stream': true,
                  'disable-gpu': true,
                  'window-size': '1920,1080',
                  geolocation: true,
                },
              } do |driver_option|
    end
  end
end
RUBY

File.write(file_path, new_content)
