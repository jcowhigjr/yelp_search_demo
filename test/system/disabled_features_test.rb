# frozen_string_literal: true

require 'application_system_test_case'


class DisabledFeaturesTest < ApplicationSystemTestCase
  setup do
    # Memory works here, as long as the same instance is shared across this thread and the app thread
    @adapter = Flipper::Adapters::Memory.new

    Flipper.configure do |config|
     config.adapter { @adapter }
    end
    Flipper.instance = nil # Ensure flipper gets reset
  end

  test 'Flipper feature should be enabled' do
    Flipper.add :early_access_preview
    Flipper.disable :early_access_preview

    assert_not_predicate Flipper[:early_access_preview], :enabled?
  end

  test 'I should not see Early Access' do

    # Flipper.add :early_access_preview
    Flipper.disable :early_access_preview

    visit '/'

    assert_text 'Coming Soon: Sign up for Early Access'
    refute_text 'Early Access Preview'
  end

end
