require 'test_helper'
require 'application_system_test_case'
class DisabledFeaturesTest < ApplicationSystemTestCase
  def setup
    Flipper.disable(:decision_wheel)
    Flipper.disable(:early_access_preview)
  end

  test "I should not see Early Access Preview" do
    visit static_home_path
    assert_no_text "Early Access Preview"
  end

  # test "I should not see Decision Wheel" do
  #   visit static_home_path
  #   assert_no_text "Decision Wheel"
  # end

  def teardown
    Flipper.disable(:early_access_preview)
    Flipper.disable(:decision_wheel)
  end

end
