## Feature Request

Add comprehensive system test coverage for mobile view functionality to ensure the application works properly across different viewport sizes.

## Background

The current system test suite primarily tests desktop viewports. With the increasing importance of mobile users, we need dedicated tests to verify the mobile experience works correctly.

## Acceptance Criteria

1. **Mobile viewport system test exists**
   - Create a new system test file `test/system/mobile_view_test.rb`
   - Test core user journeys on mobile viewport sizes
   - Verify responsive design elements work properly

2. **Mobile search flow tested**
   - Test search functionality on mobile viewport
   - Verify search results display correctly on smaller screens
   - Test navigation between search results and detail pages

3. **Mobile favorites flow tested**
   - Test favoriting functionality on mobile viewport
   - Verify favorites display properly on mobile profile page
   - Test mobile-specific UI interactions (touch targets, etc.)

4. **Mobile navigation tested**
   - Test navigation elements work properly on mobile
   - Verify back button functionality works on mobile
   - Test any mobile-specific navigation patterns

## Technical Requirements

- Use Capybara viewport resizing to test mobile screen sizes
- Focus on user-visible behavior, not implementation details
- Follow existing system test patterns and helpers
- Tests should be stable and non-brittle
- Use proper wait strategies for mobile-specific loading patterns

## Implementation Notes

- Reference existing system tests for patterns
- Use `page.driver.resize(width, height)` for viewport changes
- Consider common mobile breakpoints (375x667, 414x896, etc.)
- Ensure tests work in both headless and visible browser modes

## Related Work

- This addresses part of the scope mentioned in PR #1164 spike
- Builds on existing system test infrastructure in `test/system/`
- References mobile testing guidelines in AGENTS.md

## Definition of Done

- [ ] New mobile system test file created
- [ ] Tests pass locally and in CI
- [ ] Tests cover core mobile user journeys
- [ ] Documentation updated if needed
- [ ] No regression in existing system tests
