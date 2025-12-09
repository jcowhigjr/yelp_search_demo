# Yelp API Stub Audit - Issue #1168

**Date:** 2025-12-09  
**Purpose:** Audit all system tests using Yelp API and identify all files calling `stub_yelp_api_request()`

## Summary

This audit identifies all system tests that rely on the Yelp API stub method `stub_yelp_api_request()` defined in `test/support/yelp_api_helper.rb`.

## Stub Implementation Location

**File:** `test/support/yelp_api_helper.rb`

The `stub_yelp_api_request()` method:
- Stubs HTTP requests to `https://api.yelp.com/v3/businesses/search`
- Accepts optional parameters: `search_term`, `_latitude`, `_longitude`
- Returns mock data based on search term (coffee, yoga, pizza, taco)
- Default response: generic "Mock Business"

## Files Calling `stub_yelp_api_request()`

### 1. Base Test Configuration

#### `test/application_system_test_case.rb`
- **Line:** 25
- **Context:** Setup block for all system tests
- **Usage:** `stub_yelp_api_request` (no arguments)
- **Scope:** Global - affects all system tests inheriting from ApplicationSystemTestCase
- **Environment setup:** Also sets `ENV['YELP_API_KEY'] = 'test-key'` in setup

### 2. System Tests

#### `test/system/searches_test.rb`
- **Line:** 8
- **Context:** Setup block
- **Usage:** `stub_yelp_api_request` (no arguments)
- **Tests affected:** 3 tests
  - `An anonymous user at the static home can search by query and view results`
  - `search page displays prototype hero section and features`
  - `An anonymous user can update the query`

#### `test/system/coffeeshops_test.rb`
- **Line:** 7
- **Context:** Setup block
- **Usage:** `stub_yelp_api_request` (no arguments)
- **Tests affected:** 4 tests
  - `An unauthenticated user can view coffeeshop details`
  - `A logged in user can submit a review`
  - `A logged in user can edit and delete their review`
  - `A logged in user can favorite and unfavorite a coffeeshop`
  - `Yelp brand compliance - icon and color must be maintained`

#### `test/system/navigation_test.rb`
- **Line:** 5
- **Context:** Setup block
- **Usage:** `stub_yelp_api_request` (no arguments)
- **Tests affected:** 1 test
  - `A user can search and return using the back button`

#### `test/system/favorite_toggle_test.rb`
- **Line:** 5
- **Context:** Setup block
- **Usage:** `stub_yelp_api_request("coffee")` (with search term)
- **Line:** 101
- **Context:** Within test method
- **Usage:** `stub_yelp_api_request("pizza")` (with search term for second search)
- **Tests affected:** 3 tests
  - `logged in user can toggle favorite with contextual icons`
  - `favorite icon changes based on search term` (uses both coffee and pizza)
  - `anonymous user does not see favorite buttons`

#### `test/system/simple_favorite_test.rb`
- **Line:** 5
- **Context:** Setup block
- **Usage:** `stub_yelp_api_request` (no arguments)
- **Tests affected:** 2 tests
  - `can click favorite button and see it on profile favorites`
  - `favorites page displays prototype empty state`

#### `test/system/mobile_user_journey_test.rb`
- **Line:** 23
- **Context:** Setup block
- **Usage:** `stub_yelp_api_request("tacos")` (with search term)
- **Tests affected:** 1 test
  - `a mobile user can share their location, search for tacos, and get directions`

### 3. System Tests NOT Using Yelp API Stub

The following system tests inherit from `ApplicationSystemTestCase` but do NOT explicitly call `stub_yelp_api_request()` in their setup. However, they still receive the stub from the base class setup:

- `test/system/broadcasts_test.rb` - No Yelp API interaction
- `test/system/dark_mode_test.rb` - Uses search but relies on base class stub
- `test/system/debug_favorite_test.rb` - Uses search but relies on base class stub
- `test/system/disabled_features_test.rb` - No Yelp API interaction
- `test/system/enabled_features_test.rb` - No Yelp API interaction
- `test/system/locales_test.rb` - Some tests visit pages but don't trigger searches
- `test/system/tailwind_css_delivery_test.rb` - No Yelp API interaction
- `test/system/theme_toggle_test.rb` - No Yelp API interaction
- `test/system/users_test.rb` - No Yelp API interaction in most tests
- `test/system/sessions/login_test.rb` - No Yelp API interaction
- `test/system/sessions/logout_test.rb` - Uses search but relies on base class stub

## Test Coverage Statistics

- **Total system test files:** 18
- **Files explicitly calling `stub_yelp_api_request()`:** 8 (including base class)
- **Files with explicit setup stubs:** 7
- **Total explicit stub calls:** 9 (including 1 in-test call)
- **Files relying on base class stub only:** 11

## Search Term Usage

The stub supports contextual responses based on search terms:

| Search Term | Mock Business Name | Files Using |
|-------------|-------------------|-------------|
| "coffee" | Mock Coffee Shop | `favorite_toggle_test.rb` |
| "pizza" | Mock Pizza Place | `favorite_toggle_test.rb` |
| "tacos" / "taco" | Mock Taco Shop | `mobile_user_journey_test.rb` |
| "yoga" | Mock Yoga Studio | None explicitly |
| (no term) | Mock Business | All other tests |

## Recommendations

1. **Consolidation:** The stub in `application_system_test_case.rb` line 25 provides global coverage. Individual test file stubs may be redundant unless they need specific search term responses.

2. **Consistency:** Consider standardizing whether stubs should be:
   - Defined only in base class (DRY approach)
   - Explicitly defined in each test (explicit dependencies)

3. **Documentation:** The `yelp_api_helper.rb` could benefit from documentation explaining:
   - When to use search term parameters
   - Available mock response types
   - How to extend for new search terms

4. **Test Isolation:** Some tests may benefit from more specific stub responses to validate search-term-dependent behavior (e.g., dark_mode_test.rb performs a coffee search but doesn't use the coffee-specific stub).

## Files Summary

### Direct stub_yelp_api_request() Calls (9 total)
1. `test/application_system_test_case.rb:25` - base setup
2. `test/system/searches_test.rb:8` - setup
3. `test/system/coffeeshops_test.rb:7` - setup
4. `test/system/navigation_test.rb:5` - setup
5. `test/system/favorite_toggle_test.rb:5` - setup with "coffee"
6. `test/system/favorite_toggle_test.rb:101` - in-test with "pizza"
7. `test/system/simple_favorite_test.rb:5` - setup
8. `test/system/mobile_user_journey_test.rb:23` - setup with "tacos"

### Referenced in Documentation
9. `AGENTS.md:777` - documentation reference only

## Related Files

- **Helper implementation:** `test/support/yelp_api_helper.rb`
- **Base test case:** `test/application_system_test_case.rb`
- **Project documentation:** `AGENTS.md`, `WARP.md`
