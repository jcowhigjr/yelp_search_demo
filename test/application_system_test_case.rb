require 'test_helper'
require 'capybara'
require 'capybara/cuprite'

Capybara.default_max_wait_time = 10

# Hosts to abort in Chrome via Ferrum network interception.
# These external font/analytics domains cause Ferrum::PendingConnectionsError
# because Chrome opens connections that never close within the test timeout.
BLOCKED_HOSTS = %w[
  fonts.googleapis.com
  fonts.gstatic.com
  ga.jspm.io
].freeze

Capybara.register_driver :cuprite_mobile do |app| # rubocop:disable Metrics/BlockLength
  driver = Capybara::Cuprite::Driver.new(
    app,
    screen_size: [375, 667],
    options: {
      inspector: !ENV['HEADLESS'].in?(%w[n 0 no false]) && !ENV['MAGIC_TEST'].in?(%w[1]),
      headless: !ENV['HEADLESS'].in?(%w[n 0 no false]) && !ENV['MAGIC_TEST'].in?(%w[1]),
      js_errors: ENV.fetch('CUPRITE_JS_ERRORS', nil) == 'true',
      timeout: 60,
      process_timeout: 60,
      # Safety net: don't error on pending CDN connections that slip past interception.
      # We actively block BLOCKED_HOSTS via network interception in before_setup,
      # but Materialize/Font Awesome CDNs (cdnjs.cloudflare.com) are required and may
      # be slow in CI. Tests still validate app behavior via element assertions.
      pending_connection_errors: false,
      browser_options: {
        'no-sandbox': true,
        'disable-web-security': true,
        'auto-open-devtools-for-tabs': false,
        'disable-popup-blocking': true,
        'disable-notifications': true,
        'use-fake-device-for-media-stream': true,
        'use-fake-ui-for-media-stream': true,
        'disable-gpu': true,
        'window-size': '375,667',
        geolocation: true,
      },
    },
  )

  driver.browser.command('Browser.grantPermissions', origin: 'http://127.0.0.1:*', permissions: ['geolocation'])
  driver.browser.command('Emulation.setGeolocationOverride', latitude: 40.7128, longitude: -74.0060, accuracy: 1)
  driver
end


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
  setup do
    ENV['YELP_API_KEY'] = 'test-key'
    stub_yelp_api_request('coffee')
  end

  teardown do
    ENV.delete('YELP_API_KEY')
  end

  # these helpers help with Timeouts on go_back
  include EvilSystems::Helpers
  include OAuthTestHelper
  include LoginHelpers::System
  
  # Require search test helper
  require_relative 'support/search_test_helper'
  include SearchTestHelper
  
  # Include system test helpers for cleaner debugging
  require_relative 'support/system_test_helpers'
  include SystemTestHelpers

  if ENV.fetch('SELENIUM', nil) == 'true'
    driven_by :selenium,
              using: (ENV['SHOW_TESTS'] ? :chrome : :headless_chrome),
              screen_size: [1400, 1400] do |driver_option|
    end
  else
  driven_by :cuprite,
            screen_size: [375, 667],
            options: {
              inspector: !ENV['HEADLESS'].in?(%w[n 0 no false]) && !ENV['MAGIC_TEST'].in?(%w[1]),
              headless: !ENV['HEADLESS'].in?(%w[n 0 no false]) && !ENV['MAGIC_TEST'].in?(%w[1]),
              js_errors: ENV.fetch('CUPRITE_JS_ERRORS', nil) == 'true',
              timeout: 60,
              process_timeout: 60,
              # Safety net — see comment on cuprite_mobile driver above.
              pending_connection_errors: false,
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

  include YelpApiHelper

  setup do
    stub_yelp_api_request
  end

  # Block external font/analytics domains that cause PendingConnectionsError.
  # Runs before each test, after the browser is initialized.
  setup do
    if page.driver.respond_to?(:browser)
      page.driver.browser.network.intercept
      page.driver.browser.on(:request) do |request|
        host = begin
          URI(request.url).host
        rescue URI::InvalidURIError
          nil
        end
        if BLOCKED_HOSTS.include?(host)
          request.abort
        else
          request.continue
        end
      end
    end
  rescue StandardError => e
    # Network interception is best-effort; don't fail test setup
    debug_output("Network interception setup failed: #{e.message}")
  end

  private

  # Viewport-aware navigation helper.
  # At mobile viewport (<=600px) Materialize hides desktop nav and shows
  # the sidenav-trigger hamburger. At desktop it's the reverse.
  #
  # Raises RuntimeError if the navbar is not present (e.g. not logged in),
  # rather than producing a confusing ElementNotFound error downstream.
  def navigate_via_nav(link_text)
    unless page.has_css?('nav', wait: 3)
      raise "navigate_via_nav('#{link_text}') called but no <nav> found on page. " \
            'The navbar only renders when logged in — check that login succeeded.'
    end

    if mobile_viewport?
      open_mobile_sidenav
      find('#mobile-demo a', text: link_text, wait: 5).trigger('click')
    else
      click_on link_text
    end
  end

  # Returns true if the current browser viewport is mobile-width.
  # Only rescues Ferrum-specific errors (dead browser, JS error, timeout),
  # NOT all StandardError — unrelated exceptions must propagate.
  def mobile_viewport?
    page.evaluate_script('window.innerWidth') <= 600
  rescue Ferrum::Error
    # If we can't evaluate JS (browser dead, timeout), assume mobile
    # since the default Cuprite screen_size is 375px.
    true
  end

  # Opens the Materialize mobile sidenav.
  # Uses visible: true (not :all) so we only click triggers the user can see.
  # If the trigger is hidden (e.g. at desktop width), this correctly fails
  # rather than silently clicking an invisible element.
  def open_mobile_sidenav
    trigger = find('.sidenav-trigger', visible: true, wait: 5)
    trigger.trigger('click')
    assert_selector '#mobile-demo', visible: true, wait: 5
  end
end
