puts "Loading test_helper.rb"

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'bcrypt'

module TestPasswordHelper
  def default_password_digest
    BCrypt::Password.create(default_password, cost: 4)
  end

  def default_password
    'TerriblePassword'
  end
end

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)
  fixtures :all
  include TestPasswordHelper
  ActiveRecord::FixtureSet.context_class.send :include, TestPasswordHelper
  include ActiveJob::TestHelper

  setup do
    Rails.cache.clear
    Flipper.instance = Flipper.new(Flipper::Adapters::Memory.new)
    Flipper.instance.add(:early_access_preview)
    Flipper.instance.enable(:early_access_preview)
  end

  teardown do
    Rails.cache.clear
    Flipper.instance = nil
  end
end
Flipper.enable(:early_access_preview)
