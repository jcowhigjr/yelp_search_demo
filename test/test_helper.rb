ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

require "minitest/autorun"
require 'rails/test_help'

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

module LoginHelper
  def login(user)
    post sessions_path, params: {
      email: user.email, password: 'mypass', password_confirmation: 'mypass'
    }
  end

  def logout
    delete logout_url
  end
end

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  # include Devise::Test::IntegrationHelpers
  # include Warden::Test::Helpers
  # @controller.stubs(:current_user).returns(users(:one))
  include TestPasswordHelper
  ActiveRecord::FixtureSet.context_class.send :include, TestPasswordHelper

  include ActiveJob::TestHelper

  include LoginHelper
end

ActionCable.server.config.logger = Logger.new(STDOUT)
module ActionViewTestCaseExtensions
  def render(*arguments, **options, &block)
    ApplicationController.renderer.render(*arguments, **options, &block)
  end
end
class ActionDispatch::IntegrationTest
  include ActionViewTestCaseExtensions
end
class ActionCable::Channel::TestCase
  include ActionViewTestCaseExtensions
end

class ActionDispatch::IntegrationTest
  def assert_admin_access(url:, method: :get, **args)
    login users(:one)
    send(method, url, **args)
    assert_response :forbidden

    login users(:admin)
    send(method, url, **args)
    yield users(:admin)
  end

  def assert_login_access(url:, user: users(:one), method: :get, **args)
    logout
    send(method, url, **args)
    assert_redirected_to new_session_url

    login user
    send(method, url, **args)
    yield user
  end

  def assert_self_or_admin_access(url:, user:, method: :get, **args)
    login User.where.not(email: user.email).where.not(is_admin: true).first
    send(method, url, **args)
    assert_response :forbidden

    login users(:admin)
    send(method, url, **args)
    yield

    login user
    send(method, url, **args)
    yield
  end

  def assert_self_access(url:, user:, method: :get, **args)
    login User.where.not(email: user.email).first
    send(method, url, **args)
    assert_response :forbidden

    login user
    send(method, url, **args)
    yield user
  end
end
