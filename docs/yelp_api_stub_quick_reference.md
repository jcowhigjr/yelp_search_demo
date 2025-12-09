# Yelp API Stub Quick Reference

## Quick Summary for Issue #1168

### Implementation
- **Location:** `test/support/yelp_api_helper.rb`
- **Method:** `stub_yelp_api_request(search_term = nil, _latitude = nil, _longitude = nil)`

### All Files Using stub_yelp_api_request()

#### Base Configuration (affects all system tests)
- `test/application_system_test_case.rb:25`

#### Explicit Test File Usage
1. `test/system/searches_test.rb:8`
2. `test/system/coffeeshops_test.rb:7`
3. `test/system/navigation_test.rb:5`
4. `test/system/favorite_toggle_test.rb:5` - with "coffee" parameter
5. `test/system/favorite_toggle_test.rb:101` - with "pizza" parameter (in-test call)
6. `test/system/simple_favorite_test.rb:5`
7. `test/system/mobile_user_journey_test.rb:23` - with "tacos" parameter

#### Tests Relying on Base Class Stub Only
- `test/system/broadcasts_test.rb`
- `test/system/dark_mode_test.rb`
- `test/system/debug_favorite_test.rb`
- `test/system/disabled_features_test.rb`
- `test/system/enabled_features_test.rb`
- `test/system/locales_test.rb`
- `test/system/tailwind_css_delivery_test.rb`
- `test/system/theme_toggle_test.rb`
- `test/system/users_test.rb`
- `test/system/sessions/login_test.rb`
- `test/system/sessions/logout_test.rb`

### Statistics
- **Total explicit calls:** 8 (7 in setup blocks, 1 in test method)
- **System tests with explicit stubs:** 7 files
- **System tests relying on base class stub:** 11 files
- **Total system test files:** 18

### Search Term Support
| Term | Response |
|------|----------|
| "coffee" | Mock Coffee Shop |
| "pizza" | Mock Pizza Place |
| "tacos"/"taco" | Mock Taco Shop |
| "yoga" | Mock Yoga Studio |
| (default) | Mock Business |

For detailed analysis, see `docs/yelp_api_stub_audit.md`
