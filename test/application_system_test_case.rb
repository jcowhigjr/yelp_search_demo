require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # TODO: This can run headless  https://github.com/hotwired/turbo-rails/blob/bb5cfcbc7eb9e96668803dd9fad50fdabd8cd6aa/test/application_system_test_case.rb
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400] do |driver_option|
    # https://edgeapi.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html
    # https://dev.to/doctolib/loading-chrome-extensions-in-capybara-integration-tests-3880
    # driver_option.add_extension('/Users/temp/Library/Application Support/Google/Chrome/Default/Extensions/niijdolnjmjdjakbanogihdlhcbhfkho/1.0.2_0.crx')
    # 16) Add https://edgeapi.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html capycorder extension for building system test
    # 17) Try out https://github.com/bullet-train-co/magic_test/issues which solves a similar issue i'm having.. i don't know capybara anymore..lol
    # 18) https://evilmartians.com/chronicles/system-of-a-test-2-robust-rails-browser-testing-with-siteprism  more complex system tests for later
    # 19) Extension: /Users/temp/Library/Application Support/Google/Chrome/Default/Extensions/niijdolnjmjdjakbanogihdlhcbhfkho/1.0.2_0.crx
    # driver_option.add_extension('capycorder102.crx')
  end
  include MagicTest::Support if ENV["MAGIC_TEST"].present?

  Capybara.configure do |config|
    config.server = :puma, { Silent: true }
  end
end
