# Load general RSpec Rails configuration
# require "rails_helper.rb"

require 'capybara/ferrum'
require 'uri'

Capybara.register_driver :ferrum_block_fonts do |app|
  browser = Ferrum::Browser.new

  browser.on(:request) do |request|
    host = URI(request.url).host
    if host == 'fonts.gstatic.com'
      request.abort
    end
  end

  Capybara::Ferrum::Driver.new(app, browser:)
end

Capybara.javascript_driver = :ferrum_block_fonts

# Load configuration files and helpers
Dir[File.join(__dir__, 'system/support/**/*.rb')].each do |file|
  require file
end
