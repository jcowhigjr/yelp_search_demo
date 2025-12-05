ENV['RAILS_ENV'] ||= 'test'
ENV['HEADLESS'] ||= 'true'
ENV['CUPRITE'] ||= 'true'
ENV['APP_HOST'] ||= 'localhost'
ENV['CUPRITE_JS_ERRORS'] ||= 'false'
require 'minitest'
require 'mocha/minitest'
require_relative '../config/environment'

# require "minitest/autorun"
require 'rails/test_help'
require 'webmock/minitest'
WebMock.disable_net_connect!(allow_localhost: true)

Rails.root.glob('test/support/**/*.rb').each { |f| require f.to_s }

require 'bcrypt'
# https://brandonhilkert.com/blog/managing-login-passwords-for-capybara-with-minitest-and-rails-fixtures/
module TestPasswordHelper
  def default_password_digest
    BCrypt::Password.create(default_password, cost: 4)
  end

  def default_password
    'TerriblePassword'
  end
end

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
# module LoginHelper
#   def login(user)
#     raise 'user required' unless user.is_a? User

#     post sessions_path, params: {
#       email: user.email, password: 'TerriblePassword', password_confirmation: 'TerriblePassword'
#     }
#   end

#   #SessionsController#destroy
#   def logout
#     delete logout_url
#   end
# end

class ActiveSupport::TestCase
  # Run tests in parallel with configurable workers (default: 3) even for small suites
  parallelize(workers: ENV.fetch('RAILS_TEST_WORKERS', 3).to_i, threshold: 0)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  # include Devise::Test::IntegrationHelpers
  # include Warden::Test::Helpers
  # @controller.stubs(:current_user).returns(users(:one))
  include TestPasswordHelper
  ActiveRecord::FixtureSet.context_class.send :include, TestPasswordHelper

  include ActiveJob::TestHelper

  # include LoginHelper
  # https://github.com/rails/rails/pull/39582
  def default_url_options
    Rails.application.routes.default_url_options
  end

end

class ActionDispatch::IntegrationTest
  include LoginHelpers::Controller
end
