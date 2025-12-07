# UI: Replace footer language links with compact language selector (Fixed Requirements)

## Summary

Replace the current list of language links in the footer with a compact language selector inspired by the Website Design Improvement prototype. The selector should use the existing Rails i18n stack, live in the global layout near the theme toggle, be comfortable for thumb use on mobile, and require minimal backend changes.

**This issue addresses fundamental implementation problems identified in #1092.**

## Key Requirements (Clarified)

### 1. Language Selector Implementation
- **CRITICAL**: Use `.language-selector*` CSS classes (defined in `app/assets/stylesheets/language-selector.css`)
- **CRITICAL**: Remove footer language links completely (lines 29-46 in `_footer.html.erb`)
- Place selector in top-right near theme toggle
- Use custom dropdown implementation (NOT generic `data-controller="dropdown"`)

### 2. CSS Requirements
- Apply `.language-selector` class to main container
- Apply `.language-selector__button` class to toggle button
- Apply `.language-menu` class to dropdown container
- Apply `.language-menu__item` class to each language option
- Use CSS variables: `var(--color-bg)`, `var(--color-text)`, `var(--color-border)`, `var(--color-primary)`

### 3. Layout Integration
- Integrate `layouts/_language_selector.html.erb` into `application.html.erb`
- Remove language navigation block from `layouts/_footer.html.erb`
- Keep About/Contact/Privacy links only

### 4. Mobile Requirements
- Minimum 44x44px tap targets for button and items
- Full-width tap targets on narrow viewports
- Safe spacing from viewport edges

### 5. Accessibility Requirements
- Menu button pattern with `aria-haspopup="true"` and `aria-expanded`
- Proper keyboard navigation support
- Screen reader friendly labels

## Acceptance Criteria

1. **CSS Classes Applied Correctly**
   - Language selector uses `.language-selector*` classes from CSS file
   - No Tailwind classes for language selector styling
   - CSS variables properly applied

2. **Footer Updated Correctly**
   - Footer language links completely removed
   - Only About/Contact/Privacy remain
   - No pipe separators for languages

3. **Functionality Works**
   - Selector shows current locale code
   - Dropdown displays translated language names
   - Clicking language navigates to correct locale route
   - Updates `I18n.locale` and `<html lang=...>` attribute

4. **Mobile Responsive**
   - 44x44px minimum tap targets
   - Full-width dropdown on narrow screens
   - No clipping by viewport edges

5. **Tests Pass**
   - All existing system tests pass
   - New tests cover language switching functionality
   - No search functionality regressions

## Implementation Notes

- The CSS file already exists with proper classes - USE THEM
- Do NOT use generic dropdown controller
- Do NOT use Tailwind classes for selector styling
- Remove ALL footer language links, not just hide them
- Test with multiple locales to ensure proper functionality

## Sub-tasks to Create

1. **Layout**: Add layouts/_language_selector partial and integrate into application layout
2. **CSS**: Style language selector pill and dropdown with mobile-friendly tap targets  
3. **Tests**: Update locale and layout tests for the new language selector
4. **Playwright**: Add headless check for language switching via selector on homepage

## Key Differences from #1092

- **Explicit CSS class requirements** - no ambiguity about using existing CSS file
- **Clear footer removal requirement** - completely remove language links
- **Specific implementation constraints** - no generic dropdown controllers
- **Test requirements** - ensure no regressions in search functionality
- **Mobile-first approach** - explicit tap target requirements
