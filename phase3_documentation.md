## Phase 3: Document Yelp API stubbing patterns and ensure consistency

### Background

After implementing the stubbing improvements and error testing, we need to document the proper usage patterns and ensure consistency across all system tests. This will prevent future regressions and help developers understand how to use the stubbing infrastructure correctly.

### Acceptance Criteria

1. **Update YelpApiHelper documentation**
   - Add comprehensive comments to `test/support/yelp_api_helper.rb`
   - Document when to use each stubbing method
   - Include examples of proper usage patterns
   - Document error scenario testing approaches

2. **Create testing guidelines documentation**
   - Add section to `docs/TESTING.md` or create new file if needed
   - Document best practices for API stubbing in this project
   - Include troubleshooting guide for common stubbing issues
   - Provide examples of both positive and negative test patterns

3. **Add inline code comments**
   - Add comments to system tests explaining stub usage
   - Document why specific search terms are used
   - Add comments for any complex stubbing scenarios
   - Ensure comments are consistent across all test files

4. **Create stubbing usage examples**
   - Create example test file showing proper patterns
   - Document common scenarios and their solutions
   - Include template code for new system tests
   - Add examples for both success and error scenarios

### Documentation Structure

#### In `test/support/yelp_api_helper.rb`
```ruby
module YelpApiHelper
  # Stubs successful Yelp API responses for testing search functionality.
  #
  # @param search_term [String, nil] The search term to generate contextually appropriate mock data.
  #   - "coffee" → "Mock Coffee Shop"
  #   - "yoga" → "Mock Yoga Studio" 
  #   - "pizza" → "Mock Pizza Place"
  #   - "taco" → "Mock Taco Shop"
  #   - nil/other → "Mock Business"
  #
  # @example Search for coffee shops
  #   stub_yelp_api_request("coffee")
  #   fill_in 'search[query]', with: 'coffee'
  #   click_on 'Search'
  #   assert_text 'Mock Coffee Shop'
  #
  # @example Generic search (legacy usage)
  #   stub_yelp_api_request
  #   # Returns "Mock Business" regardless of search term
  def stub_yelp_api_request(search_term = nil, _latitude = nil, _longitude = nil)
    # ... implementation
  end

  # Stubs Yelp API error responses for testing error handling.
  #
  # @param error_type [Symbol] The type of error to simulate
  #   - :server_error - HTTP 500 internal server error
  #   - :rate_limit - HTTP 429 rate limiting
  #   - :timeout - Network timeout
  #   - :malformed - Invalid JSON response
  #
  # @example Test server error handling
  #   stub_yelp_api_error(:server_error)
  #   visit new_search_path
  #   # ... perform search
  #   assert_text 'Something went wrong'
  def stub_yelp_api_error(error_type = :server_error)
    # ... implementation  
  end
end
```

#### In testing documentation
```markdown
## API Stubbing Guidelines

### Yelp API Testing

This project uses custom helpers for stubbing Yelp API responses in system tests.

#### Success Scenarios

Use `stub_yelp_api_request(search_term)` for testing successful searches:

```ruby
# Recommended: Pass search term for contextually appropriate responses
stub_yelp_api_request("coffee")
fill_in 'search[query]', with: 'coffee'
click_on 'Search'
assert_text 'Mock Coffee Shop'  # Matches search context

# Legacy: Generic response (avoid in new tests)
stub_yelp_api_request  # Returns "Mock Business"
```

#### Error Scenarios

Use `stub_yelp_api_error(error_type)` for testing error handling:

```ruby
# Test server error
stub_yelp_api_error(:server_error)
# Test rate limiting  
stub_yelp_api_error(:rate_limit)
# Test timeout
stub_yelp_api_error(:timeout)
```

#### Best Practices

1. **Always pass search terms** to ensure test data matches search context
2. **Test error scenarios** in addition to success cases
3. **Use descriptive assertions** that verify user-visible behavior
4. **Keep tests isolated** - don't rely on shared state between tests
```

### Files to Update

- `test/support/yelp_api_helper.rb` - Add comprehensive method documentation
- `docs/TESTING.md` - Add API stubbing guidelines (or create if doesn't exist)
- `test/system/searches_test.rb` - Add inline comments explaining stub usage
- `test/system/simple_favorite_test.rb` - Add inline comments
- `test/system/navigation_test.rb` - Add inline comments
- `test/system/yelp_api_errors_test.rb` - Add comments when created in Phase 2

### Additional Improvements

1. **Add helper method validation**
   - Add input validation for error_type parameter
   - Raise helpful errors for invalid usage
   - Document error messages

2. **Create usage validation**
   - Add linting rules or tests to catch improper stub usage
   - Ensure all new tests follow documented patterns
   - Add CI checks for consistency

3. **Update test templates**
   - Ensure new test generators use proper stubbing patterns
   - Update any test scaffolding tools

### Definition of Done

- [ ] All Yelp API helper methods are fully documented
- [ ] Testing guidelines are created and comprehensive
- [ ] All system tests using Yelp API have inline comments
- [ ] Documentation examples are clear and accurate
- [ ] New developers can easily understand proper stubbing patterns
- [ ] Existing tests follow documented patterns consistently

### Risk Level: LOW
- Purely documentation and consistency improvements
- No functional code changes required
- High confidence in delivery
- Easy to verify completeness

### Estimated Effort: 2-3 hours
- Helper documentation: 1 hour
- Testing guidelines: 1 hour
- Inline comments: 1 hour

### Dependencies
- Phase 1 and Phase 2 should be completed first
- Documentation should reflect the final state of the stubbing infrastructure

### Success Metrics
- New team members can write proper API tests without guidance
- Code reviews consistently catch improper stub usage
- Test maintenance becomes easier with clear patterns
- Future spike work builds on documented foundations
