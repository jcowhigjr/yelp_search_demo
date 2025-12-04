# Language Selector CSS Classes

## Overview

This document describes the CSS classes created for the language selector button and dropdown menu, implemented to solve GitHub issue #1094.

## Files Created

1. **app/assets/stylesheets/language-selector.css** - Complete CSS for language selector component
2. **app/views/layouts/_language_selector_example.html.erb** - Example ERB partial demonstrating usage

## CSS Classes

### Button Classes

- `.language-selector` - Container for the language selector component
- `.language-selector__button` - The button that triggers the dropdown
  - Minimum 44x44px tap target (48x48px on mobile)
  - Uses `aria-haspopup` and `aria-expanded` for accessibility
- `.language-selector__icon` - Icon within the button (rotates when open)

### Dropdown Classes

- `.language-menu` - The dropdown menu container
  - Uses `role="menu"` for accessibility
  - Controlled by `data-open` attribute
- `.language-menu__item` - Individual language option links
  - Minimum 44x44px tap target (48px on mobile)
  - Full-width tap areas on narrow viewports
  - Uses `role="menuitem"` for accessibility
- `.language-menu__item--active` - Active/current language indicator

## Accessibility Features

### Mobile Accessibility (WCAG 2.1 Level AA)

- ✅ Minimum 44x44px touch targets on desktop (Guideline 2.5.5)
- ✅ Minimum 48x48px touch targets on mobile viewports
- ✅ Full-width tap areas for language rows on narrow viewports (<768px)

### Keyboard Accessibility

- ✅ Proper focus indicators using `--color-primary`
- ✅ `:focus-visible` support for keyboard navigation
- ✅ ARIA attributes: `aria-haspopup`, `aria-expanded`, `aria-label`, `role`

### Visual Accessibility

- ✅ High contrast ratios using design tokens
- ✅ Hover and focus states clearly visible
- ✅ Smooth transitions for better UX

## Design Tokens Used

All colors use CSS variables from `design-tokens.css`:

- `--color-bg` - Background color
- `--color-bg-secondary` - Hover background
- `--color-bg-tertiary` - Active background
- `--color-text` - Text color
- `--color-primary` - Brand color for active states
- `--color-border` - Border color
- `--color-border-secondary` - Hover border
- `--color-shadow` - Box shadow

These tokens automatically adapt to light/dark mode themes.

## Responsive Behavior

### Desktop (>768px)

- Button: 44x44px minimum, padding 8px 16px
- Dropdown: Right-aligned, minimum 200px width
- Menu items: 44px minimum height, 12px 16px padding

### Mobile (≤768px)

- Button: 48x48px minimum, padding 12px 20px
- Dropdown: Full-width, spans entire container
- Menu items: 48px minimum height, 16px padding, full-width

## Implementation Example

See `app/views/layouts/_language_selector_example.html.erb` for a complete implementation example including:

- Proper HTML structure with ARIA attributes
- Example JavaScript for dropdown toggle behavior
- Integration with Rails I18n system

## JavaScript Requirements

The CSS provides styling only. JavaScript is required to:

1. Toggle `aria-expanded` attribute on button click
2. Toggle `data-open` attribute on menu
3. Close dropdown when clicking outside
4. Handle keyboard navigation (optional enhancement)

Example JavaScript is included in the example ERB partial as comments.

## Testing

The CSS classes are compatible with the existing system test in `test/system/locales_test.rb`, which checks for:

- `button[aria-haspopup]` selector
- `[role="menu"]` and `.language-menu` selectors
- Language option text presence

All tests pass with the new CSS classes.

## Browser Support

- Modern browsers (Chrome, Firefox, Safari, Edge)
- Uses standard CSS3 features
- `color-mix()` for transparent color mixing (fallback: use rgba)
- CSS custom properties (widely supported)

## Future Enhancements

- Add keyboard navigation JavaScript
- Add smooth close animation
- Add mobile swipe-to-close gesture
- Consider adding language flags/icons

## Related Files

- `app/assets/stylesheets/navigation.css` - Existing navigation styles
- `app/assets/stylesheets/design-tokens.css` - Color variables
- `app/views/layouts/_footer.html.erb` - Current language links in footer
- `test/system/locales_test.rb` - System tests for language selector
