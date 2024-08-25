require 'test_helper'
# require 'capybara'
require 'capybara/cuprite'

require 'evil_systems'
EvilSystems.initial_setup

# some features for example geolocation require https://www.chromium.org/Home/chromium-security/prefer-secure-origins-for-powerful-new-features/
# in this case the remote testing feature where the server is hosted on the .local network for testing is not a secure
# origin  https://github.com/ParamagicDev/evil_systems
# APP_HOST=127.0.0.1 SHOW_TESTS=1 CUPRITE=true bin/rails test:system fixed it
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase

  # setup do
  #   # Precompile assets before running the tests
  #   system 'bin/rails tailwindcss:build'
  # end

  # these seem to be missing on CI so we need to add them manually
  include EvilSystems::CupriteHelpers

  # include EvilSystems::Helpers
  # if ENV.fetch('CUPRITE', nil) == 'true'

  driven_by :cuprite,
            screen_size: [375, 667],
            options: {
              js_errors: ENV.fetch('CUPRITE_JS_ERRORS', nil) == 'true',
              # Increase Chrome startup wait time (required for stable CI builds)
              process_timeout: 10,
              # See additional options for Dockerized environment in the respective section of this article
              browser_options: {'no-sandbox': nil},
              # Enable debugging capabilities
              inspector: !ENV['HEADLESS'].in?(%w[n 0 no false]) && !ENV['MAGIC_TEST'].in?(%w[1]),
              # Allow running Chrome in a headful mode by setting HEADLESS env
              # var to a falsey value
              headless: !ENV['HEADLESS'].in?(%w[n 0 no false]) && !ENV['MAGIC_TEST'].in?(%w[1]),
            } do |driver_option|
              driver_option.add_emulation(device_name: 'iPhone 6')
              driver_option.browser_options({'no-sandbox': nil})

            # # save local crx for extensions: https://thebyteseffect.com/posts/crx-extractor-features/
            # if ENV['SHOW_TESTS']
            #   driver_option.add_extension('capycorder102.crx')
            #   driver_option.add_extension('RailsPanel.crx')
            #   # driver_option.add_extension('LiveReload.crx')
            # end
  end





  # Minitest::Retry.on_failure do |klass, test_name, result|
  #   # retry if Capybara::ElementNotFound
  #   if result.exception.is_a?(Capybara::ElementNotFound)
  #     puts "ElementNotFound: #{result.exception.message}"
  #     retry
  #   end
  #   # retry if Capybara::CapybaraError
  #   if result.exception.is_a?(Capybara::CapybaraError)
  #     puts "CapybaraError: #{result.exception.message}"
  #     retry
  #   end
  #   # retry if Capybara::CapybaraInternalServerError
  #   if result.exception.is_a?(Capybara::CapybaraInternalServerError)
  #     puts "CapybaraInternalServerError: #{result.exception.message}"
  #     retry
  #   end
  #   # retry if Capybara::CapybaraNetworkError
  #   if result.exception.is_a?(Capybara::CapybaraNetworkError)
  #     puts "CapybaraNetworkError: #{result.exception.message}"
  #     retry
  #   end
  #   # retry if Capybara::CapybaraNotSupportedError
  #   if result.exception.is_a?(Capybara::CapybaraNotSupportedError)
  #     puts "CapybaraNotSupportedError: #{result.exception.message}"
  #     retry
  #   end
  #   # retry if Capybara::CapybaraServerError
  #   if result.exception.is_a?(Capybara::CapybaraServerError)
  #     puts "CapybaraServerError: #{result.exception.message}"
  #     retry
  #   end
  #   # retry if Capybara::CapybaraTimeoutError
  #   if result.exception.is_a?(Capybara::CapybaraTimeoutError)
  #     puts "CapybaraTimeoutError: #{result.exception.message}"
  #     retry
  #   end
  #   # retry if Capybara::CapybaraUnsupportedFeatureError
  #   if result.exception.is_a?(Capybara::CapybaraUnsupportedFeatureError)
  #     puts "CapybaraUnsupportedFeatureError"
  #     retry
  #   end
  # end

  # Capybara.configure do |config|
  #   config.server = :puma, { Silent: true }
  # end
end
