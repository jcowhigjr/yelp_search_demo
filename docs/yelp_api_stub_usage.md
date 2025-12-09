# Yelp API stub usage in system tests

## Helper behavior
- `test/support/yelp_api_helper.rb` defines `stub_yelp_api_request` to intercept `GET https://api.yelp.com/v3/businesses/search` and return JSON shaped like a Yelp search response.
- The helper picks the mocked business name from the `search_term` passed into the stub: `coffee` → "Mock Coffee Shop", `yoga` → "Mock Yoga Studio", `pizza` → "Mock Pizza Place", `taco` → "Mock Taco Shop", anything else → "Mock Business".
- `ApplicationSystemTestCase` calls `stub_yelp_api_request` in `setup`, so every system test starts with a default stub (no search term provided) unless the test overrides it.

## Call sites and search terms
- `test/application_system_test_case.rb`: `setup` calls `stub_yelp_api_request` with no term to provide a default stub for all system tests.
- `test/system/navigation_test.rb`: `setup` calls `stub_yelp_api_request` with no term; the test searches for `tacos`, so the response uses the default "Mock Business" name.
- `test/system/searches_test.rb`: `setup` calls `stub_yelp_api_request` with no term; tests submit queries `yoga` and `coffee`, relying on the default stubbed payload.
- `test/system/simple_favorite_test.rb`: `setup` calls `stub_yelp_api_request` with no term; searches use `coffee`, still backed by the default stub response.
- `test/system/favorite_toggle_test.rb`: `setup` calls `stub_yelp_api_request("coffee")` to return "Mock Coffee Shop" results; the second test also calls `stub_yelp_api_request("pizza")` before issuing a pizza search to switch the mocked business name.
- `test/system/coffeeshops_test.rb`: `setup` calls `stub_yelp_api_request` with no term; the flows that perform searches use `coffee` while relying on the default stubbed response.
- `test/system/mobile_user_journey_test.rb`: `setup` calls `stub_yelp_api_request("tacos")` so the mobile flow searching for `tacos` gets the "Mock Taco Shop" payload.
