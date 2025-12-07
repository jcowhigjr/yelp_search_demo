## Phase 1: Fix existing Yelp API stub usage in system tests

### Background

Currently, system tests inconsistently use `stub_yelp_api_request()` - some pass search terms, others don't. This creates semantic misalignment where tests search for "coffee" but receive generic "Mock Business" responses.

### Acceptance Criteria

1. **Audit all system tests using Yelp API**
   - Identify all files calling `stub_yelp_api_request()`
   - Document current usage patterns and search terms used
   - Note any inconsistencies between search queries and stub responses

2. **Update stub calls to pass search terms**
   - Update `test/system/simple_favorite_test.rb` to pass "coffee" (already done in PR #1164)
   - Update `test/system/searches_test.rb` to pass appropriate search terms ("yoga", etc.)
   - Update `test/system/navigation_test.rb` to pass "tacos" search term
   - Update any other system tests using Yelp API stubs

3. **Verify test data alignment**
   - Ensure mock business names match search contexts (Mock Coffee Shop for coffee, etc.)
   - Verify all tests still pass with the more specific stubs
   - Run full system test suite to ensure no regressions

### Technical Details

- Use existing `yelp_api_response(search_term)` method in `YelpApiHelper`
- Leverage the search term logic already implemented:
  - "coffee" → "Mock Coffee Shop"
  - "yoga" → "Mock Yoga Studio" 
  - "pizza" → "Mock Pizza Place"
  - "taco" → "Mock Taco Shop"
  - fallback → "Mock Business"

### Files to Modify

- `test/system/simple_favorite_test.rb` (already done)
- `test/system/searches_test.rb` 
- `test/system/navigation_test.rb`
- Any other system test files using `stub_yelp_api_request()`

### Definition of Done

- [ ] All system tests pass search terms to Yelp API stubs
- [ ] Mock data matches search context in all tests
- [ ] System test suite passes without regressions
- [ ] No functional changes to application behavior
- [ ] Tests maintain current performance characteristics

### Risk Level: LOW
- Uses existing helper functionality
- Minimal code changes
- High confidence in delivery
- Easy to verify and rollback if needed

### Estimated Effort: 2-4 hours
- Audit: 1 hour
- Updates: 1-2 hours  
- Testing and verification: 1 hour
