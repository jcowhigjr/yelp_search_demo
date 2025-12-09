ENV['RAILS_ENV'] ||= 'test'

# Set default environment variables for system tests
# These ensure system tests work consistently without manual setup
ENV['HEADLESS'] = ENV.fetch('HEADLESS', 'true')
ENV['CUPRITE'] = ENV.fetch('CUPRITE', 'true')
ENV['APP_HOST'] = ENV.fetch('APP_HOST', 'localhost')
ENV['CUPRITE_JS_ERRORS'] = ENV.fetch('CUPRITE_JS_ERRORS', 'false')

require 'minitest'
require 'mocha/minitest'
require_relative '../config/environment'
require 'securerandom'
require 'socket'
require 'tmpdir'

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
  def self.process_parallelization_available?
    socket_path = File.join(Dir.tmpdir, "rails-parallel-#{Process.pid}-#{SecureRandom.hex(4)}")
    UNIXServer.new(socket_path).close
    File.delete(socket_path)
    true
  rescue Errno::EACCES, Errno::EPERM => e
    warn "[test] Falling back to thread-based test runs because #{e.class}: #{e.message}"
    false
  ensure
    File.delete(socket_path) if defined?(socket_path) && File.exist?(socket_path)
  end

  process_workers = ENV.fetch("RAILS_TEST_WORKERS", 3).to_i
  thread_workers = ENV.fetch("RAILS_TEST_THREAD_WORKERS", 1).to_i

  # Prefer process-based parallelization when the environment allows DRb sockets; otherwise
  # fallback to thread-based, single-worker execution to avoid cross-test stubbing conflicts.
  if process_parallelization_available?
    parallelize(workers: process_workers, threshold: 0)
  else
    parallelize(workers: thread_workers, threshold: 0, with: :threads)
  end

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
