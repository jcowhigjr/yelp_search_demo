require 'test_helper'

class CoffeeshopTest < ActiveSupport::TestCase
  API_RESPONSE = {
    'businesses' => [{
      'name' => 'Test Coffee Shop',
      'rating' => 4.5,
      'url' => 'https://yelp.com/test',
      'image_url' => 'https://example.com/image.jpg',
      'display_phone' => '(555) 123-4567',
      'location' => { 'display_address' => ['123 Test St', 'Test City, CA'] },
    }],
  }.to_json.freeze

  # test "the truth" do
  #   assert true
  # end
  setup do
    @coffeeshop = coffeeshops(:one)
  end
  test 'coffeeshop attributes must not be empty' do
    @coffeeshop.rating = nil

    assert_not @coffeeshop.valid?
  end
  test 'coffeeshop rating must be between 1 and 5' do
    assert_predicate @coffeeshop, :valid?
    @coffeeshop.rating = 0

    assert_not @coffeeshop.valid?
    @coffeeshop.rating = 5.5

    assert_not @coffeeshop.valid?
    @coffeeshop.rating = 1.5

    assert_predicate @coffeeshop, :valid?
    @coffeeshop.rating = 1

    assert_predicate @coffeeshop, :valid?
  end

  test 'prefers the environment API key over Rails credentials' do
    Rails.application.credentials.stubs(:dig).with(:yelp, :api_key).returns('credentials-key')
    stub_yelp_response_with_authorization('environment-key')

    with_yelp_api_key('environment-key') do
      Coffeeshop.get_search_results(@coffeeshop.search)
    end

    assert_requested :get, %r{api\.yelp\.com/v3/businesses/search},
                     headers: { 'Authorization' => 'Bearer environment-key' }
  end

  test 'falls back to Rails credentials when the environment key is blank' do
    Rails.application.credentials.stubs(:dig).with(:yelp, :api_key).returns('credentials-key')
    stub_yelp_response_with_authorization('credentials-key')

    with_yelp_api_key('') do
      Coffeeshop.get_search_results(@coffeeshop.search)
    end

    assert_requested :get, %r{api\.yelp\.com/v3/businesses/search},
                     headers: { 'Authorization' => 'Bearer credentials-key' }
  end

  test 'returns a generic error without logging the exception message' do
    stub_request(:get, %r{api\.yelp\.com/v3/businesses/search})
      .with(headers: { 'Authorization' => 'Bearer environment-key' })
      .to_return(status: 401, body: 'sensitive Yelp response')
    log = StringIO.new
    Rails.stubs(:logger).returns(Logger.new(log))

    with_yelp_api_key('environment-key') do
      assert_equal 'error: Unable to connect to Yelp. Please try again later.',
                   Coffeeshop.get_search_results(@coffeeshop.search)
    end

    assert_match(/RestClient::Unauthorized.*HTTP 401/, log.string)
    assert_no_match(/sensitive Yelp response/, log.string)
  end

  private

  def with_yelp_api_key(value)
    original = ENV.fetch('YELP_API_KEY', nil)
    value.nil? ? ENV.delete('YELP_API_KEY') : ENV['YELP_API_KEY'] = value
    yield
  ensure
    original.nil? ? ENV.delete('YELP_API_KEY') : ENV['YELP_API_KEY'] = original
  end

  def stub_yelp_response_with_authorization(api_key)
    stub_request(:get, %r{api\.yelp\.com/v3/businesses/search})
      .with(headers: { 'Authorization' => "Bearer #{api_key}" })
      .to_return(status: 200, body: API_RESPONSE)
  end
end
