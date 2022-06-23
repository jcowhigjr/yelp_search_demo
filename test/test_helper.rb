ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

# require "minitest/autorun"
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

  # include LoginHelper
  # https://github.com/rails/rails/pull/39582
  def default_url_options
    Rails.application.routes.default_url_options
  end

end

