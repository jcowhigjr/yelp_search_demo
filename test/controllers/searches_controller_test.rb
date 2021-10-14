require 'test_helper'

class SearchesControllerTest < ActionDispatch::IntegrationTest

  test "should redirect get search to post new" do
    get new_search_path
    assert_response :redirect
    #TODO: test redirect search path ActionController::UrlGenerationError:  route matches {:action=>"show", :controller=>"searches"}, missing required keys: [:id]
    # assert_redirected_to search_path
  end
end
