# YelpApiHelper - Extended API Stubbing Patterns

## Overview

The `YelpApiHelper` module provides comprehensive API stubbing capabilities for testing Yelp API interactions without making real HTTP requests. This ensures tests are fast, reliable, and don't depend on external services.

## Phase 2 Enhancements

### New Helper Methods

#### Success Scenarios
```ruby
stub_yelp_api_success(search_term = 'coffee', latitude = 40.748817, longitude = -73.985428)
```
Stubs a successful API response with a single business result.

#### Error Scenarios
```ruby
stub_yelp_api_error(search_term = 'coffee', latitude = 40.748817, longitude = -73.985428)
```
Stubs a 500 internal server error response.

#### Empty Results
```ruby
stub_yelp_api_empty(search_term = 'coffee', latitude = 40.748817, longitude = -73.985428)
```
Stubs a successful response with no businesses found.

#### Rate Limiting
```ruby
stub_yelp_api_rate_limited(search_term = 'coffee', latitude = 40.748817, longitude = -73.985428)
```
Stubs a 429 rate limit exceeded response.

#### Multiple Results
```ruby
stub_yelp_api_multiple_results(search_term = 'coffee', latitude = 40.748817, longitude = -73.985428)
```
Stubs a successful response with multiple business results (3 businesses).

#### Custom Data
```ruby
stub_yelp_api_with_custom_data(search_term, latitude, longitude, custom_response)
```
Allows stubbing with completely custom response data for advanced testing scenarios.

#### Cleanup
```ruby
clear_yelp_api_stubs
```
Clears all WebMock stubs - useful for test isolation.

### Backwards Compatibility

The original `stub_yelp_api_request` method is maintained and enhanced:

```ruby
stub_yelp_api_request(search_term, latitude, longitude, scenario: :success)
```

Now supports a `scenario` parameter with the following options:
- `:success` (default)
- `:error`
- `:empty`
- `:rate_limited`
- `:multiple_results`

## Usage Examples

### Basic Usage
```ruby
class MySystemTest < ApplicationSystemTestCase
  test 'search works with default data' do
    # Uses existing setup - stub_yelp_api_success is called automatically
    visit new_search_path
    fill_in 'search[query]', with: 'coffee'
    click_on 'search'
    
    assert_text 'Mock Coffee Shop'
  end
end
```

### Testing Error Conditions
```ruby
class ErrorHandlingTest < ApplicationSystemTestCase
  test 'handles API errors gracefully' do
    clear_yelp_api_stubs
    stub_yelp_api_error('coffee')
    
    visit new_search_path
    fill_in 'search[query]', with: 'coffee'
    click_on 'search'
    
    # Assert error handling behavior
    assert_text 'Sorry, something went wrong'
  end
end
```

### Testing Different Search Terms
```ruby
class ParameterizedSearchTest < ApplicationSystemTestCase
  test 'supports different search terms' do
    %w[pizza sushi thai].each do |term|
      clear_yelp_api_stubs
      stub_yelp_api_success(term)
      
      visit new_search_path
      fill_in 'search[query]', with: term
      click_on 'search'
      
      assert_text "Mock #{term.capitalize} Shop"
    end
  end
end
```

### Testing Custom Scenarios
```ruby
class CustomDataTest < ApplicationSystemTestCase
  test 'handles custom business data' do
    custom_data = {
      "businesses": [{
        "name": "Special Test Restaurant",
        "rating": 4.9,
        "url": "https://example.com/special",
        "display_phone": "(555) 999-8888",
        "location": { "display_address": ["789 Special St", "Test City"] }
      }]
    }
    
    clear_yelp_api_stubs
    stub_yelp_api_with_custom_data('special', 40.748817, -73.985428, custom_data)
    
    visit new_search_path
    fill_in 'search[query]', with: 'special'
    click_on 'search'
    
    assert_text 'Special Test Restaurant'
  end
end
```

## Response Data Structure

### Success Response
```json
{
  "businesses": [
    {
      "name": "Mock {SearchTerm} Shop",
      "rating": 4.5,
      "url": "https://www.yelp.com/biz/mock-{searchterm}-shop-seattle",
      "image_url": "https://s3-media3.fl.yelpcdn.com/bphoto/mock.jpg",
      "display_phone": "(206) 555-1212",
      "location": {
        "display_address": ["123 Mock St", "Seattle, WA 98101"]
      }
    }
  ]
}
```

### Error Response
```json
{
  "error": {
    "code": "INTERNAL_ERROR",
    "description": "An internal error occurred. Please try again later."
  }
}
```

### Empty Response
```json
{
  "businesses": [],
  "total": 0
}
```

### Rate Limit Response
```json
{
  "error": {
    "code": "ACCESS_LIMIT_REACHED",
    "description": "You have exceeded the request limit. Please try again later."
  }
}
```

## Best Practices

1. **Use specific helpers**: Prefer `stub_yelp_api_success` over `stub_yelp_api_request` for common scenarios.

2. **Clear stubs when needed**: Use `clear_yelp_api_stubs` when testing different scenarios in the same test.

3. **Test error conditions**: Don't just test the happy path - verify error handling too.

4. **Use realistic data**: When using custom data, make it representative of real Yelp responses.

5. **Keep tests isolated**: Each test should set up its own stubs and not rely on others.

## Migration from Phase 1

Existing tests will continue to work unchanged. The setup in `ApplicationSystemTestCase` now uses `stub_yelp_api_success` instead of `stub_yelp_api_request`, but the behavior is identical.

To take advantage of new features, simply replace:
```ruby
# Old way
stub_yelp_api_request('coffee', lat, lng)

# New way - more explicit and feature-rich
stub_yelp_api_success('coffee', lat, lng)
```

## Architecture

The helper is organized into:
- **Public interface**: High-level helper methods for common scenarios
- **Core method**: `stub_yelp_api_request` with scenario support
- **Response generators**: Private methods that create appropriate JSON responses
- **Utilities**: Cleanup and custom data support

This provides a clean API while maintaining flexibility for complex testing needs.
