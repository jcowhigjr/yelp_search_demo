# API Stubbing Guidelines

This guide explains how we stub external APIs in tests. It complements `test/test_helper.rb`, where WebMock is enabled and real HTTP calls are blocked (`WebMock.disable_net_connect!(allow_localhost: true)`).

## Best practices
- **Stub every external call**: Tests must not hit the network. Add explicit stubs for each endpoint you expect and keep `allow_localhost: true` for Capybara/system tests.
- **Use helpers over ad-hoc stubs**: Prefer shared helpers under `test/support/` (for example, `YelpApiHelper#stub_yelp_api_request`) so responses stay consistent across tests.
- **Match real request shapes**: Include required headers, query params, and bodies in stubs. Use `hash_including` for optional params, and set `Content-Type` headers to mirror the real API.
- **Return deterministic payloads**: Keep responses small, realistic, and stable. Favor fixtures or helper methods instead of inline JSON strings scattered in tests.
- **Assert behavior, not implementation**: After stubbing, assert user-visible outcomes (rendered text, records created) and optionally use `assert_requested` to confirm the stub ran.
- **Reset between examples when needed**: WebMock resets between tests via Minitest, but if you mutate stubs inside a test, clean up with `WebMock.reset!` in `teardown` to avoid leaks.

## Positive patterns
- **Use shared helper with realistic response**
  ```ruby
  # test/support/yelp_api_helper.rb already provides this
  class SearchFlowTest < ActionDispatch::IntegrationTest
    include YelpApiHelper

    test "returns mock results" do
      stub_yelp_api_request("coffee")

      get search_path(query: "coffee")

      assert_response :success
      assert_includes response.body, "Mock Coffee Shop"
      assert_requested(:get, "https://api.yelp.com/v3/businesses/search")
    end
  end
  ```
- **Tightly scoped stub with headers and query expectations**
  ```ruby
  stub_request(:get, "https://api.example.com/v1/users")
    .with(headers: { "Authorization" => "Bearer token" }, query: { page: "1" })
    .to_return(status: 200, body: { users: [] }.to_json, headers: { "Content-Type" => "application/json" })
  ```
- **Negative response tests**
  ```ruby
  stub_request(:get, %r{api.example.com/v1/users}).to_return(status: 500, body: "{}")

  assert_raises(Api::Error) { ApiClient.new.users }
  ```

## Anti-patterns to avoid
- **Overly broad stubs**: `stub_request(:any, %r{api.example.com})` can hide unexpected calls or missing params. Scope stubs to exact paths and methods.
- **Disabling WebMock**: Avoid `WebMock.allow_net_connect!` or changing global settings to “fix” a test. Add the missing stub instead.
- **Copy/pasted JSON blobs**: Large inline JSON makes tests brittle. Move payloads into helpers or fixtures so they can be reused and updated centrally.
- **Testing stub configuration instead of behavior**: Asserting on `WebMock` call counts without asserting the user-facing outcome misses regressions. Pair `assert_requested` with functional assertions.

## Troubleshooting
- **"Real HTTP connections are disabled" errors**: The request was not stubbed or URL/headers mismatch. Confirm the exact URL, HTTP method, and params; mirror them in your stub.
- **"No matching stub" with query params**: WebMock matches params exactly. Use `hash_including` for optional params or ensure param order matches what the client sends.
- **Unexpected 200/500 responses**: Double-check test data. Ensure your stub returns the desired status/body and that the client parses `Content-Type` correctly.
- **Stubs leaking across tests**: If a test mutates stubs (e.g., calling `remove_request_stub`), add `teardown { WebMock.reset! }` in that test class to restore defaults.
- **System tests hitting real APIs**: Ensure helpers run before the page loads. Add stubs in `setup` for system tests and keep `allow_localhost: true` intact for Capybara.

## Where to add new stubs
- Add reusable helpers to `test/support/` and require them in `test/test_helper.rb` if needed.
- For single-use scenarios, add stubs in the test `setup` block or within the test body, keeping scope narrow and expectations explicit.
