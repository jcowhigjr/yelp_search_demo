## Phase 1: Remove language links from footer

### Problem

The footer currently contains language navigation links mixed with footer links, making it cluttered and confusing. Language selection should be moved to the navbar to improve UX.

### Current State

Footer contains:
- About, Contact, Privacy links (should remain)
- Language links with separators (should be removed)
- Early access/coming soon text (should be removed)

### Acceptance Criteria

1. **Clean up footer content**
   - Remove entire language navigation section from footer
   - Keep only About, Contact, Privacy links
   - Remove language separators and legacy `language-nav` classes
   - Remove early access/coming soon text

2. **Maintain footer structure**
   - Footer layout remains the same (copyright + links)
   - No breaking changes to footer styling
   - Footer remains responsive on mobile

### Files to Modify

- `app/views/layouts/_footer.html.erb` - Remove language navigation section

### Definition of Done

- [ ] Language links completely removed from footer
- [ ] Only About, Contact, Privacy links remain
- [ ] No language-related CSS classes in footer
- [ ] Footer layout and styling unchanged
- [ ] All existing tests still pass

### Risk Level: LOW
- Simple content removal
- No functional changes
- Easy to verify and rollback

### Dependencies

- **No dependencies** - This phase can be completed independently
- **Prerequisite for**: Phase 2 (#1174) - Navbar selector

### GitHub Relationships

**Blocks:** #1174

### Deployment Order

**Can be deployed first** - This is a cleanup phase that removes language links from the footer without affecting other functionality.

### Estimated Effort: 1-2 hours
- Footer cleanup: 30 minutes
- Testing and verification: 30-60 minutes

### Success Metrics

- Footer is clean and focused on essential links
- No language selection UI in footer
- Mobile footer remains usable
