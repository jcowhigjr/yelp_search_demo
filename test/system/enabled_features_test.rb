require 'test_helper'
require 'application_system_test_case'

class EnabledFeaturesTest < ApplicationSystemTestCase

  test "I should see Early Access Preview" do
    Flipper.instance.enable(:decision_wheel)
    puts "Flipper state in setup: early_access_preview enabled: #{Flipper.instance.enabled?(:early_access_preview)}"
    puts "Flipper state before visit: early_access_preview enabled: #{Flipper.instance.enabled?(:early_access_preview)}"
    visit static_home_path
    puts "Page content: #{page.body}"
    assert_text "Early Access Preview"
  end

end
puts "Flipper state after enabling: early_access_preview enabled: {Flipper.instance.enabled?(:early_access_preview)}"
puts "Page content after visit: {page.body}"
