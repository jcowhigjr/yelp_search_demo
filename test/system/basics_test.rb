require "application_system_test_case"

require "minitest/autorun"
require "minitest/focus"
# require "minitest/retry"
# Minitest::Retry.use!

# Minitest::Retry.on_failure do |klass, test_name, result|
#   ENV['SHOW_TESTS'] = 'false'
#   # ENV['CUPRITE'] = 'true'
# end
class BasicsTest < ApplicationSystemTestCase

  test "home is a search page" do
    skip 'this is too redundant'
  end
end
