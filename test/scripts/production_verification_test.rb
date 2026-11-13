require 'minitest/autorun'
require 'tmpdir'
require_relative '../../lib/build_revision'
require_relative '../../scripts/production-search-verification'

class ProductionVerificationTest < Minitest::Test
  SHA = 'a' * 40
  OTHER = 'b' * 40
  Response = Struct.new(:code, :body, :headers) do
    def [](name)
      headers[name.downcase]
    end

    def get_fields(name)
      value = self[name]
      value ? [value] : nil
    end
  end

  def response(code: '200', body: 'OK', revision: SHA, location: nil)
    Response.new(code, body, { 'x-app-revision' => revision, 'location' => location, 'set-cookie' => 'session=opaque; Secure; HttpOnly' })
  end

  def run_probe(responses)
    @requests = []
    transport = lambda do |uri, cookie, form|
      @requests << { uri: uri, cookie: cookie, form: form }
      responses.shift || raise('Unexpected extra request')
    end
    ProductionSearchVerification.new(expected: SHA, transport: transport, pause: -> {}, attempts: 2).run
  end

  def home
    response(body: '<form><input value="token&amp;value" name="authenticity_token"></form>')
  end

  def result
    response(body: '<div class="search-results"><div class="coffeeshop-card">Cafe</div></div>')
  end

  def test_two_fresh_searches_are_bound_to_expected_revision
    evidence = run_probe([
      response, home, response(code: '302', location: '/searches/10'), result,
      home, response(code: '303', location: '/searches/11'), result
    ])

    assert_equal 'passed', evidence[:result]
    assert_equal 2, evidence[:checks].size
    forms = @requests.filter_map { |item| item[:form] }
    assert_equal ['coffee ', 'espresso '], forms.map { |form| form['search[query]'] }
    assert_equal 'token&value', forms.first['authenticity_token']
    refute_includes JSON.generate(evidence), 'opaque'
    refute_includes JSON.generate(evidence), 'token&value'
  end

  def test_unknown_or_old_release_never_submits_a_search
    evidence = run_probe([response(revision: OTHER), response(revision: 'unknown')])

    assert_equal 'failed', evidence[:result]
    assert @requests.none? { |item| item[:form] }
  end

  def test_rollout_waits_for_expected_revision
    evidence = run_probe([
      response(revision: OTHER), response, home, response(code: '302', location: '/searches/10'), result,
      home, response(code: '302', location: '/searches/11'), result
    ])

    assert_equal 'passed', evidence[:result]
    assert_equal ['/healthz', '/healthz'], @requests.first(2).map { |item| item[:uri].path }
  end

  def test_revision_change_on_results_fails_verification
    evidence = run_probe([response, home, response(code: '302', location: '/searches/10'), response(body: 'search-results coffeeshop-card', revision: OTHER)])

    assert_equal 'failed', evidence[:result]
    assert_match(/revision changed/, evidence[:error])
  end

  def test_collection_redirect_is_rejected
    evidence = run_probe([response, home, response(code: '302', location: '/searches')])

    assert_equal 'failed', evidence[:result]
    assert_equal 3, @requests.size
  end

  def test_cross_origin_redirect_never_receives_session_cookie
    evidence = run_probe([response, home, response(code: '302', location: 'https://attacker.example/searches/10')])

    assert_equal 'failed', evidence[:result]
    assert @requests.all? { |item| item[:uri].host == 'dorkbob.herokuapp.com' }
    assert_equal 3, @requests.size
  end

  def test_wrong_revision_on_post_stops_before_following_redirect
    evidence = run_probe([response, home, response(code: '302', location: '/searches/10', revision: OTHER)])

    assert_equal 'failed', evidence[:result]
    assert_equal 3, @requests.size
  end

  def test_build_artifact_is_validated_and_stale_metadata_cleared
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'build_revision')
      assert_equal 'unknown', BuildRevision.current(path: path)
      BuildRevision.capture(SHA, path: path)
      assert_equal SHA, BuildRevision.current(path: path)
      BuildRevision.capture(nil, path: path)
      assert_equal 'unknown', BuildRevision.current(path: path)
      assert_raises(ArgumentError) { BuildRevision.capture('not-a-commit', path: path) }
    end
  end
end
