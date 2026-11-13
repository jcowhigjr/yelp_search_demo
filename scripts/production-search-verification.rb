require 'net/http'
require 'uri'
require 'cgi'
require 'json'
require 'time'

class ProductionSearchVerification
  ORIGIN = URI('https://dorkbob.herokuapp.com').freeze
  CASES = [
    ['coffee ', '35.933449', '-79.029773'],
    ['espresso ', '35.907751', '-78.991132']
  ].freeze

  class Failure < StandardError; end

  def initialize(expected:, transport: nil, pause: -> { sleep 15 }, attempts: 20)
    raise Failure, 'Expected revision is not a full Git SHA' unless expected.match?(/\A[0-9a-f]{40}\z/)

    @expected = expected
    @transport = transport || method(:http)
    @pause = pause
    @attempts = attempts
  end

  def run
    evidence = { checked_at: Time.now.utc.iso8601, expected_revision: @expected, checks: [], result: 'failed' }
    begin
      wait_for_revision
      CASES.each { |input| evidence[:checks] << search(*input) }
      evidence[:result] = 'passed'
    rescue Failure => error
      evidence[:error] = error.message
    rescue StandardError => error
      evidence[:error] = error.class.name
    end
    evidence
  end

  private

  def wait_for_revision
    @attempts.times do |index|
      response = request('/healthz')
      return if response.code == '200' && response.body.strip == 'OK' && response['X-App-Revision'] == @expected

      @pause.call if index + 1 < @attempts
    end
    raise Failure, 'Expected revision did not become healthy before deadline'
  end

  def search(query, latitude, longitude)
    home = request('/')
    require_response(home, '200')
    input = home.body.scan(/<input\b[^>]*>/i).find { |tag| attributes(tag)['name'] == 'authenticity_token' }
    token = input && CGI.unescapeHTML(attributes(input).fetch('value', ''))
    raise Failure, 'Missing CSRF token' if token.nil? || token.empty?

    cookie = cookies(home)
    post = request('/searches', cookie, {
      'authenticity_token' => token, 'search[query]' => query,
      'search[latitude]' => latitude, 'search[longitude]' => longitude
    })
    require_response(post, '302', '303')
    target = production_uri(post['location'].to_s)
    raise Failure, 'Search did not redirect to a saved search' unless target.path.match?(%r{\A/searches/\d+\z})

    updated_cookie = cookies(post)
    result = request(target.to_s, updated_cookie.empty? ? cookie : updated_cookie)
    require_response(result, '200')
    raise Failure, 'Search results or business cards missing' unless result.body.include?('search-results') && result.body.include?('coffeeshop-card')

    { query: query, result: 'passed', revision: @expected, post_status: post.code.to_i,
      redirect_path: target.path, get_status: result.code.to_i }
  end

  def require_response(response, *codes)
    raise Failure, 'Unexpected HTTP status' unless codes.include?(response.code)
    raise Failure, 'Serving revision changed during search verification' unless response['X-App-Revision'] == @expected
  end

  def request(path, cookie = nil, form = nil)
    uri = production_uri(path)
    @transport.call(uri, cookie, form)
  end

  def production_uri(path)
    uri = URI.join(ORIGIN.to_s, path)
    allowed = uri.scheme == ORIGIN.scheme && uri.host == ORIGIN.host && uri.port == ORIGIN.port
    raise Failure, 'Refusing redirect outside production origin' unless allowed && uri.userinfo.nil? && uri.fragment.nil?

    uri
  end

  def http(uri, cookie, form)
    request = form ? Net::HTTP::Post.new(uri) : Net::HTTP::Get.new(uri)
    request['Cookie'] = cookie if cookie
    request['Cache-Control'] = 'no-cache, no-store'
    request['User-Agent'] = 'DorkBob-Production-Verification'
    if form
      request['Origin'] = ORIGIN.to_s
      request.set_form_data(form)
    end
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 15) do |client|
      client.request(request)
    end
  end

  def cookies(response)
    (response.get_fields('set-cookie') || []).map { |value| value.split(';', 2).first }.join('; ')
  end

  def attributes(tag)
    tag.scan(/([\w-]+)\s*=\s*["']([^"']*)["']/).to_h
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    evidence = ProductionSearchVerification.new(expected: ENV.fetch('EXPECTED_SHA', '')).run
  rescue StandardError => error
    evidence = { result: 'failed', error: error.class.name }
  end
  File.write('production-verification-evidence.json', JSON.pretty_generate(evidence))
  puts JSON.pretty_generate(evidence)
  if ENV['GITHUB_STEP_SUMMARY']
    File.open(ENV['GITHUB_STEP_SUMMARY'], 'a') do |file|
      file.puts "## Production verification\n\nResult: **#{evidence[:result]}**\n\nExpected revision: #{evidence[:expected_revision]}"
      file.puts evidence[:error] if evidence[:error]
      evidence.fetch(:checks, []).each { |check| file.puts "- #{check[:query].inspect}: #{check[:result]}, #{check[:redirect_path]}, HTTP #{check[:get_status]}" }
    end
  end
  exit(evidence[:result] == 'passed' ? 0 : 1)
end
