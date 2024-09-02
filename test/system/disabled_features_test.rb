require 'test_helper'
require 'application_system_test_case'
class DisabledFeaturesTest < ApplicationSystemTestCase
  def setup
    Flipper.disable(:decision_wheel)
    Flipper.disable(:early_access_preview)
  end

  test "I should not see Early Access Preview" do
    puts "Flipper state in setup: early_access_preview enabled: #{Flipper.instance.enabled?(:early_access_preview)}"
    visit static_home_path
    assert_no_text "Early Access Preview"
  end

  # test "I should not see Decision Wheel" do
  #   puts "Flipper state in setup: decision_wheel enabled: #{Flipper.instance.enabled?(:decision_wheel)}"
  #   visit static_home_path
  #   assert_no_text "Decision Wheel"
  # end

  def teardown
    Flipper.disable(:early_access_preview)
    # Clear the asset cache after the test
    # Rails.application.assets.cache.clear
  end

end
