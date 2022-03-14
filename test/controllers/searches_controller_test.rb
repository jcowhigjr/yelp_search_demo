require 'test_helper'

class SearchesControllerTest < ActionDispatch::IntegrationTest
  test 'should redirect get search to post new' do
    get new_search_path
    assert_response :redirect
    assert_redirected_to searches_path
  end
end
