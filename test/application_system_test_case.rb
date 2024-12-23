require 'test_helper'
require 'capybara'
require 'capybara/cuprite'


# evil systems speeds up the tests but repeats the rebuilds.. need to look into it
require 'evil_systems'
EvilSystems.initial_setup

# Boot process completed
# Rebuilding...
# Done in 584ms.
# 🐢  Precompiling assets.
# Rebuilding...
# Done in 648ms.
# Finished in 2.18 seconds

# some features for example geolocation require https://www.chromium.org/Home/chromium-security/prefer-secure-origins-for-powerful-new-features/
# in this case the remote testing feature where the server is hosted on the .local network for testing is not a secure
# origin  https://github.com/ParamagicDev/evil_systems
# APP_HOST=127.0.0.1 SHOW_TESTS=1 CUPRITE=true bin/rails test:system fixed it
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase

  # setup do
  #   # Precompile assets before running the tests
  #   system 'bin/rails tailwindcss:build'
  # end

  include EvilSystems::Helpers

  if ENV.fetch('SELENIUM', nil) == 'true'
    # https://github.com/bullet-train-co/magic_test/wiki/Magic-Test-and-Cuprite
    # TODO: This can run headless  https://github.com/hotwired/turbo-rails/blob/bb5cfcbc7eb9e96668803dd9fad50fdabd8cd6aa/test/application_system_test_case.rb
    driven_by :selenium,
              using: (ENV['SHOW_TESTS'] ? :chrome : :headless_chrome),
              screen_size: [1400, 1400] do |driver_option|
      # https://edgeapi.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html
      # https://dev.to/doctolib/loading-chrome-extensions-in-capybara-integration-tests-3880
      # 16) Add https://edgeapi.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html capycorder extension for
      # 17) Try out https://github.com/bullet-train-co/magic_test/issues which solves a similar issue i'm having
      # 18) https://evilmartians.com/chronicles/system-of-a-test-2-robust-rails-browser-testing-with-sitepris
      # Enable debugging capabilities

      # save local crx for extensions: https://thebyteseffect.com/posts/crx-extractor-features/
      # if ENV['SHOW_TESTS']
      #   driver_option.add_extension('capycorder102.crx')
      #   driver_option.add_extension('RailsPanel.crx')
      #   # driver_option.add_extension('LiveReload.crx')
      #   include MagicTest::Support
      # end
    end
  else
  driven_by :cuprite,
            screen_size: [375, 667],
            options: {
              # # Enable debugging capabilities
              inspector: !ENV['HEADLESS'].in?(%w[n 0 no false]) && !ENV['MAGIC_TEST'].in?(%w[1]),
              # # Allow running Chrome in a headful mode by setting HEADLESS env
              # # var to a falsey value
              headless: !ENV['HEADLESS'].in?(%w[n 0 no false]) && !ENV['MAGIC_TEST'].in?(%w[1]),
              js_errors: ENV.fetch('CUPRITE_JS_ERRORS', nil) == 'true',
              timeout: 10,
              process_timeout: 10,
              browser_options: {
                'no-sandbox': nil,
                'disable-web-security': nil,
                'auto-open-devtools-for-tabs': false,
                'disable-popup-blocking': true,
                'disable-notifications': true,
                'use-fake-device-for-media-stream': true,
                'use-fake-ui-for-media-stream': true,
                geolocation: true,
              },
            } do |driver_option|
      # Mock geolocation
      driver_option.browser.command('Browser.grantPermissions',
                                    origin: 'http://127.0.0.1',
                                    permissions: ['geolocation'],
      )
      driver_option.browser.command('Emulation.setGeolocationOverride',
                                    latitude: 0.0,
                                    longitude: 0.0,
                                    accuracy: 100,
      )
    end
  end

  Capybara.configure do |config|
    config.server = :puma, { Silent: true }
  end
end
