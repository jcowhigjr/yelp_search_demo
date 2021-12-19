require "test_helper"

class LayoutsTest < ActionDispatch::IntegrationTest
  test 'static home root has search link' do
    get static_home_url
  end
end
