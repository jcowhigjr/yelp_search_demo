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

  CONNECTION_ERRORS = [
    SocketError,
    Errno::ECONNREFUSED,
    Errno::ECONNRESET,
    JSON::ParserError,
  ].freeze

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

  test 'encodes the user query as one Yelp term parameter' do
    search = @coffeeshop.search
    query = 'coffee & tea#fresh=1'
    search.update!(query:)
    captured_request = nil
    stub_request(:get, %r{api\.yelp\.com/v3/businesses/search})
      .with(headers: { 'Authorization' => 'Bearer environment-key' })
      .to_return do |request|
        captured_request = request
        { status: 200, body: API_RESPONSE }
      end

    with_yelp_api_key('environment-key') do
      Coffeeshop.get_search_results(search)
    end

    assert captured_request
    params = URI.decode_www_form(captured_request.uri.query).to_h
    assert_equal query, params['term']
    assert_equal %w[latitude longitude term], params.keys.sort
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

  CONNECTION_ERRORS.each do |error_class|
    test "returns a generic error for #{error_class} without logging details" do
      RestClient::Request.stubs(:execute).raises(error_class.new('sensitive upstream details'))
      log = StringIO.new
      Rails.stubs(:logger).returns(Logger.new(log))

      with_yelp_api_key('environment-key') do
        assert_equal 'error: Unable to connect to Yelp. Please try again later.',
                     Coffeeshop.get_search_results(@coffeeshop.search)
      end

      assert_match(/#{Regexp.escape(error_class.name)}/, log.string)
      assert_no_match(/sensitive upstream details/, log.string)
    end
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
