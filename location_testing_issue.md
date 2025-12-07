## Feature: Improve location testing with real API integration

## Feature Request

Add comprehensive location testing that uses real geolocation and Yelp API services to ensure the application works properly with actual external services, while maintaining test reliability and performance.

## Background

The current system tests use stubbed/mocked responses for both location services and Yelp API. While this provides test isolation, it doesn't verify that the application actually works with real external APIs. We need integration tests that validate the complete flow with real services.

## Problem Statement

1. **No real API testing**: Current tests only validate mocked behavior, not actual API integration
2. **Location API gaps**: Limited testing of geolocation functionality with real coordinates
3. **Yelp API integration**: No verification that the app actually works with real Yelp data
4. **Error handling gaps**: Missing tests for real-world API failures and edge cases

## Acceptance Criteria

1. **Real location API integration test**
   - Create a test that uses actual geolocation API (or realistic simulation)
   - Test location-based search with real coordinates
   - Verify proper handling of location permissions and errors
   - Test different geographic locations and their impact on results

2. **Real Yelp API integration test**
   - Create a test that makes actual API calls to Yelp (with proper test API keys)
   - Test real search queries and response handling
   - Verify proper parsing of real Yelp response format
   - Test handling of rate limits and API errors

3. **Integration test infrastructure**
   - Set up proper test configuration for real API calls
   - Implement VCR/WebMock for recording and replaying real API responses
   - Create test data management for real API responses
   - Ensure tests can run both with and without real API access

4. **Error scenario testing**
   - Test network failures and timeouts
   - Test API rate limiting behavior
   - Test invalid API keys and authentication failures
   - Test malformed API responses

## Technical Requirements

- Use VCR (Video Cassette Recorder) or WebMock for recording real API responses
- Implement proper test isolation to avoid hitting rate limits
- Create test configuration for API keys and credentials
- Ensure tests can run in CI environments
- Maintain test performance and reliability
- Follow security best practices for API key management

## Implementation Approach

### Phase 1: Infrastructure Setup
1. Add VCR/WebMock gems to test dependencies
2. Configure VCR cassettes for API recording
3. Set up test environment variables for API keys
4. Create test helpers for real API integration

### Phase 2: Location API Testing
1. Create `test/integration/location_api_test.rb`
2. Test geolocation permission flows
3. Test coordinate-based searches
4. Test location error scenarios

### Phase 3: Yelp API Testing
1. Create `test/integration/yelp_api_test.rb`
2. Test real search queries with Yelp API
3. Test response parsing and data handling
4. Test API error scenarios

### Phase 4: End-to-End Integration
1. Create comprehensive integration test
2. Test complete user journey with real APIs
3. Verify UI behavior with real data
4. Test performance with real API calls

## Files to Consider

- `Gemfile.test` - Add VCR/WebMock dependencies
- `test/integration/` - New integration test directory
- `test/support/vcr_helper.rb` - VCR configuration
- `test/support/api_integration_helper.rb` - Real API testing helpers
- `.env.test.local` - Test API keys configuration
- `test/integration/location_api_test.rb` - Location API tests
- `test/integration/yelp_api_test.rb` - Yelp API tests

## API Key Management

- Use environment variables for API keys in tests
- Document required test API keys in README
- Implement fallback to stubbed responses when keys not available
- Ensure test API keys have appropriate rate limits

## VCR Configuration

```ruby
# Example VCR setup
VCR.configure do |config|
  config.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.filter_sensitive_data('<YELP_API_KEY>') { ENV['YELP_API_KEY'] }
  config.filter_sensitive_data('<LOCATION_API_KEY>') { ENV['LOCATION_API_KEY'] }
end
```

## Test Categories

### Integration Tests (with real APIs)
- Run manually or in specific CI pipelines
- Require valid API keys
- Test against real API responses
- Slower but more comprehensive

### Hybrid Tests (VCR recorded)
- Use recorded real responses
- Can run in any environment
- Fast and reliable
- Maintain real-world response characteristics

### Unit Tests (stubs only)
- Continue using existing stubbed tests
- Fast execution for CI
- Test business logic independently
- Maintain test coverage

## Related Work

- Complements stubbing improvements in Issue #1166
- Supports mobile testing initiatives in Issue #1165
- Addresses integration testing gaps identified in PR #1164

## Definition of Done

- [ ] VCR/WebMock infrastructure is set up
- [ ] Location API integration tests are created and passing
- [ ] Yelp API integration tests are created and passing
- [ ] Tests can run with both real and recorded responses
- [ ] API key management is secure and documented
- [ ] Integration tests are documented in testing guidelines
- [ ] CI configuration supports optional integration test runs

## Risks and Mitigations

- **Risk**: API rate limiting in CI/CD
  - **Mitigation**: Use VCR recordings for CI, real APIs for local testing
- **Risk**: Exposing API keys in test code
  - **Mitigation**: Use environment variables and proper filtering
- **Risk**: Test reliability with external dependencies
  - **Mitigation**: Implement proper fallbacks and retry logic
- **Risk**: Performance impact on test suite
  - **Mitigation**: Keep integration tests separate from fast unit tests

## Success Metrics

- Integration tests provide confidence in real API functionality
- Test suite performance remains acceptable
- Documentation enables easy setup for new developers
- Error handling is robust for production scenarios
