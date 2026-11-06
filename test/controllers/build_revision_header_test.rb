require 'test_helper'

class BuildRevisionHeaderTest < ActionDispatch::IntegrationTest
  test 'health and search responses identify the serving build' do
    revision = 'a' * 40
    BuildRevision.stubs(:current).returns(revision)

    get healthz_url

    assert_response :ok
    assert_equal revision, response.headers['X-App-Revision']
    assert_equal 'OK', response.body

    get static_home_url

    assert_response :ok
    assert_equal revision, response.headers['X-App-Revision']
  end
end
