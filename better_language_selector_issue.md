## Replace Language links with New Language Selector

### Problem

The current language navigation in the footer is cluttered and hard to use. Users need a more accessible and intuitive way to switch languages from the main navigation area.

### Current State

- Language links are buried in footer with separators
- Poor mobile experience and accessibility
- Language switching is not prominent
- Mixed concerns in footer (navigation + language selection)

### Solution Overview

This feature has been broken down into 4 manageable phases for better delivery confidence:

1. **Phase 1: Remove language links from footer** (#1173) - Clean up footer
2. **Phase 2: Add language selector to navbar** (#1174) - Core functionality  
3. **Phase 3: Implement accessibility and mobile optimizations** (#1175) - ARIA & mobile
4. **Phase 4: Add tests for language selector** (#1176) - Test coverage

### Implementation Strategy

**Why sub-issues are valuable:**
- **Reduced complexity** - Each phase has clear, focused scope
- **Parallel development** - Phases can be worked on independently
- **Risk mitigation** - Issues can be identified and fixed early
- **Better testing** - Each phase can be validated separately
- **Easier reviews** - Smaller, focused PRs are easier to review

**Phase dependencies:**
- Phase 1: Independent (can be done anytime)
- Phase 2: Depends on Phase 1 completion
- Phase 3: Depends on Phase 2 completion  
- Phase 4: Depends on Phases 1-3 completion

### High-Level Acceptance Criteria

1. **Footer cleanup** - Language links removed, only essential links remain
2. **Navbar language selector** - Current locale visible, dropdown with all languages
3. **Functional language switching** - Updates locale, routes, and html[lang] correctly
4. **Accessibility compliance** - WCAG 2.1 AA compliant keyboard and screen reader support
5. **Mobile optimization** - 44x44px minimum tap targets, responsive dropdown
6. **Comprehensive testing** - System, integration, and accessibility tests

### Technical Approach

**Phase 1 (Footer Cleanup):**
- Remove language navigation section from `_footer.html.erb`
- Keep About, Contact, Privacy links only
- Remove language separators and legacy classes

**Phase 2 (Navbar Selector):**
- Add language selector to desktop navbar
- Simple dropdown with current locale display
- Basic JavaScript for toggle functionality
- Maintain existing navbar styling

**Phase 3 (Accessibility & Mobile):**
- Add proper ARIA attributes and roles
- Implement full keyboard navigation
- Mobile-first responsive design
- Focus management and screen reader support

**Phase 4 (Testing):**
- System tests for UI behavior
- Integration tests for locale routing
- Mobile responsive testing
- Accessibility testing

### Files to be Modified

- `app/views/layouts/_footer.html.erb` - Remove language navigation
- `app/views/layouts/_navbar.html.erb` - Add language selector
- `app/assets/stylesheets/navigation.css` - Add dropdown and responsive styles
- `app/assets/javascripts/` - Add language selector functionality
- `test/system/` - Add comprehensive test coverage
- `test/integration/` - Add locale routing tests

### Risk Assessment

**Low Risk Phases:**
- Phase 1: Simple content removal
- Phase 4: Test additions only

**Medium Risk Phases:**
- Phase 2: Navbar layout changes
- Phase 3: Accessibility and responsive design

**Mitigation Strategies:**
- Incremental delivery allows early feedback
- Each phase can be rolled back independently
- Comprehensive testing prevents regressions
- Existing functionality is preserved

### Success Metrics

- Users can easily see current language in navbar
- Language switching is intuitive and fast
- WCAG 2.1 AA compliance achieved
- Mobile experience is touch-friendly
- 100% test coverage for new functionality
- No regressions in existing features

### Definition of Done

This epic is complete when:
- [ ] All 4 sub-issues are completed and merged
- [ ] Language selector works in navbar
- [ ] Footer is clean and focused
- [ ] All accessibility requirements met
- [ ] Mobile experience is optimized
- [ ] All tests pass
- [ ] No regressions in existing functionality

### Related Issues

- Sub-issue #1173: Phase 1 - Remove language links from footer
- Sub-issue #1174: Phase 2 - Add language selector to navbar  
- Sub-issue #1175: Phase 3 - Implement accessibility and mobile optimizations
- Sub-issue #1176: Phase 4 - Add tests for language selector

### Previous Attempts

- PR #1163 attempted to implement this but failed due to:
  - Breaking existing functionality (search form issues)
  - Overly complex implementation with unnecessary dependencies
  - Poor scoping leading to test failures
  - Lack of incremental approach

This phased approach addresses those issues by:
- Breaking work into manageable, testable chunks
- Preserving existing functionality
- Adding comprehensive test coverage
- Following accessibility best practices from the start
