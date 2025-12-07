## Phase 2: Add Yelp API error scenario testing to system tests

### Background

Current system tests only test successful Yelp API responses. We need to test error scenarios to ensure the application handles API failures gracefully and provides appropriate user feedback.

### Acceptance Criteria

1. **Add API error stubbing helpers**
   - Create `stub_yelp_api_error(error_type)` method in `YelpApiHelper`
   - Support different error types: 500 errors, timeouts, rate limits
   - Support malformed responses and network errors
   - Maintain backward compatibility with existing stub methods

2. **Test API failure scenarios**
   - Add test for 500 server error during search
   - Add test for API timeout during search
   - Add test for rate limiting (429) response
   - Add test for malformed JSON response
   - Add test for network connection error

3. **Verify error handling UI behavior**
   - Test that error messages are displayed to users
   - Test that search forms remain functional after errors
   - Test that loading states are properly cleared
   - Test that users can retry searches after errors

4. **Create dedicated error test file**
   - Create `test/system/yelp_api_errors_test.rb` for comprehensive error testing
   - Organize tests by error type for clarity
   - Include setup and teardown for error scenarios
   - Ensure tests are independent and don't affect other tests

### Technical Implementation

#### New Helper Methods
```ruby
# In test/support/yelp_api_helper.rb
def stub_yelp_api_error(error_type = :server_error)
  case error_type
  when :server_error
    stub_request(:get, "https://api.yelp.com/v3/businesses/search")
      .to_return(status: 500, body: { error: "Internal Server Error" }.to_json)
  when :rate_limit
    stub_request(:get, "https://api.yelp.com/v3/businesses/search")
      .to_return(status: 429, body: { error: "Rate Limit Exceeded" }.to_json)
  when :timeout
    stub_request(:get, "https://api.yelp.com/v3/businesses/search")
      .to_timeout
  when :malformed
    stub_request(:get, "https://api.yelp.com/v3/businesses/search")
      .to_return(status: 200, body: "invalid json")
  end
end
```

#### Test Structure
```ruby
# In test/system/yelp_api_errors_test.rb
class YelpApiErrorsTest < ApplicationSystemTestCase
  test "displays error message when API returns 500 error" do
    stub_yelp_api_error(:server_error)
    
    visit new_search_path
    fill_in 'search[query]', with: 'coffee'
    click_on 'Search'
    
    assert_text 'Something went wrong. Please try again.'
    assert_selector 'form[action="/searches"]' # Form still usable
  end

  test "handles rate limiting gracefully" do
    stub_yelp_api_error(:rate_limit)
    # ... test implementation
  end

  # Additional error scenario tests
end
```

### Files to Create/Modify

- `test/support/yelp_api_helper.rb` - Add error stubbing methods
- `test/system/yelp_api_errors_test.rb` - New error test file
- `test/system/searches_test.rb` - May need updates for error handling

### Error Scenarios to Test

1. **HTTP 500 Server Error**
   - Verify error message display
   - Test retry functionality
   - Ensure search form remains usable

2. **HTTP 429 Rate Limiting**
   - Test rate limit message
   - Test retry after delay behavior
   - Test user guidance for rate limits

3. **Network Timeout**
   - Test timeout handling
   - Test connection error message
   - Test retry mechanism

4. **Malformed Response**
   - Test JSON parsing error handling
   - Test fallback behavior
   - Test error logging (if applicable)

### Definition of Done

- [ ] Error stubbing helper methods are implemented
- [ ] All error scenario tests are created and passing
- [ ] Error UI behavior is verified and user-friendly
- [ ] Tests are isolated and don't affect other system tests
- [ ] Existing system tests continue to pass
- [ ] Error handling follows application error patterns

### Risk Level: MEDIUM
- Involves creating new test infrastructure
- Requires understanding of current error handling patterns
- Moderate confidence in delivery
- Tests may reveal existing error handling gaps

### Estimated Effort: 4-6 hours
- Helper methods: 1-2 hours
- Error tests: 2-3 hours
- Integration and verification: 1-2 hours

### Dependencies
- Phase 1 should be completed first to establish consistent stubbing patterns
- May require minor updates to error handling in production code if gaps are discovered
