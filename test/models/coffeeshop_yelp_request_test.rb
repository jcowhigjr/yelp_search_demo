require 'test_helper'

class CoffeeshopYelpRequestTest < ActiveSupport::TestCase
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

  setup do
    @coffeeshop = coffeeshops(:one)
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

  CONNECTION_ERRORS.each do |error_class|
    test "returns a generic error for #{error_class} without logging details" do
      assert_generic_error_for(error_class)
    end
  end

  private

  def assert_generic_error_for(error_class)
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

  def with_yelp_api_key(value)
    original = ENV.fetch('YELP_API_KEY', nil)
    value.nil? ? ENV.delete('YELP_API_KEY') : ENV['YELP_API_KEY'] = value
    yield
  ensure
    original.nil? ? ENV.delete('YELP_API_KEY') : ENV['YELP_API_KEY'] = original
  end
end
