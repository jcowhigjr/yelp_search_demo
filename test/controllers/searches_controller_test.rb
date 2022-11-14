require 'test_helper'

class SearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @search = searches(:one)
    @coffeeshop = coffeeshops(:one)
    @review = reviews(:one)
  end

  test '#new' do
    get new_search_url

    assert_response :success
    assert_select 'form'
  end

  test '#create' do
    assert_difference('Search.count') do
      post searches_path, params: { search: { query: 'tacos' } }
    end

    assert_response :found
    assert_equal 'Successfully created search.', flash[:success]
  end

  test '#show' do
    get search_url(@search, locale: nil)

    assert_response :success
    assert_select 'h2',
                  "Top Rated Searches for #{@search.query} near you!",
                  match: :second
  end

  test '#update' do
    post searches_path, params: { search: { query: 'tacos' } }
    @search = Search.last
    patch search_url(@search.id), params: { search: { query: 'yoga' } }

    assert_response :found
    assert_equal 'Successfully updated search.', flash[:success]
  end

  test '#update changes query' do
    post searches_path, params: { search: { query: 'yoga' } }
    @search = Search.last
    # puts Coffeeshop.pluck(:name)
    patch search_url(@search.id), params: { search: { query: 'tacos' } }
    # puts Coffeeshop.pluck(:name)
    assert_equal 'tacos', @search.reload.query
  end
  # test '#index' do
  #   get searches_url
  #   assert_response :success
  #   assert_select 'h2', 'Top Rated Searches', match: :first
  # end
end
