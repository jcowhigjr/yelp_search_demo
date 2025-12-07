## Tech Debt: Improve Yelp API stubbing and mocking in system tests

## Problem Statement

The current Yelp API stubbing in system tests has several issues that impact test reliability and maintainability:

1. **Inconsistent stub usage**: Some tests call `stub_yelp_api_request()` without parameters, others pass search terms
2. **Generic mock responses**: The stub returns generic data that doesn't always match the search context
3. **Limited test isolation**: Tests share the same stub implementation, making it hard to test edge cases
4. **Missing error scenarios**: No tests for API failures, rate limits, or network errors

## Current State Analysis

From PR #1164 review, we identified:
- `stub_yelp_api_request()` in `test/support/yelp_api_helper.rb` has optional `search_term` parameter
- The helper can generate different mock data based on search terms (coffee, yoga, pizza, taco)
- However, most system tests don't pass the search term, resulting in generic "Mock Business" responses
- This creates semantic misalignment between what users search for and what tests expect

## Acceptance Criteria

1. **Improve stub specificity**
   - Update all system tests to pass appropriate search terms to `stub_yelp_api_request()`
   - Ensure mock data matches the actual search queries used in tests
   - Remove ambiguous stub calls that don't specify search context

2. **Enhanced error scenario testing**
   - Add tests for API failure scenarios (500 errors, timeouts)
   - Add tests for rate limiting responses
   - Add tests for malformed API responses
   - Ensure graceful error handling in the UI

3. **Better test isolation**
   - Create helper methods for common stub scenarios
   - Allow tests to customize specific aspects of API responses
   - Enable testing of edge cases without affecting other tests

4. **Documentation and consistency**
   - Document the proper usage of Yelp API stubbing helpers
   - Add comments explaining when to use different stub configurations
   - Ensure consistent patterns across all system tests

## Technical Requirements

- Maintain backward compatibility during the transition
- Use existing `YelpApiHelper` module as the foundation
- Follow Rails testing best practices
- Ensure tests remain fast and reliable
- Don't introduce external dependencies for mocking

## Implementation Approach

1. **Phase 1: Fix existing stub usage**
   - Audit all system tests using Yelp API
   - Update calls to pass appropriate search terms
   - Verify test data matches search context

2. **Phase 2: Enhance stub capabilities**
   - Add methods for error scenario stubbing
   - Create customizable response builders
   - Add support for different API response formats

3. **Phase 3: Add comprehensive error tests**
   - Create dedicated tests for error handling
   - Test UI behavior during API failures
   - Verify user feedback mechanisms work

## Files to Consider

- `test/support/yelp_api_helper.rb` - Main stubbing logic
- `test/system/searches_test.rb` - Search functionality tests
- `test/system/simple_favorite_test.rb` - Favorite functionality tests
- `test/system/navigation_test.rb` - Navigation tests
- `test/system/coffeeshops_test.rb` - Coffee shop detail tests

## Related Work

- Addresses tech debt identified in PR #1164 spike review
- Builds on existing `yelp_api_response()` method improvements
- Supports better mobile testing (Issue #1165)

## Definition of Done

- [ ] All system tests use specific search terms in Yelp API stubs
- [ ] Error scenario tests are added and passing
- [ ] Stubbing helpers are documented and consistent
- [ ] Test suite maintains or improves performance
- [ ] No regression in existing functionality
- [ ] Code comments explain stub usage patterns

## Risks and Mitigations

- **Risk**: Breaking existing tests during refactoring
  - **Mitigation**: Make changes incrementally with thorough testing
- **Risk**: Over-engineering the stub solution
  - **Mitigation**: Focus on practical improvements, not perfect abstraction
- **Risk**: Performance impact from more complex stubs
  - **Mitigation**: Measure test execution times and optimize as needed
