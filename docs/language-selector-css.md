# Language Selector CSS Classes

## Overview
CSS classes for implementing an accessible language selector button with dropdown menu. These styles follow WCAG 2.1 mobile accessibility guidelines with minimum 44x44px tap targets.

## Classes

### Container
- `.language-selector` - Wrapper element for the button and dropdown

### Button
- `.language-selector__button` - Primary button to open/close dropdown
  - Minimum 44x44px tap target (48px on mobile)
  - Uses design system color variables
  - Includes hover, focus, and active states
- `.language-selector__button--open` - Modifier class when dropdown is open

### Dropdown
- `.language-selector__dropdown` - Dropdown menu container
  - Hidden by default
  - Positioned absolutely below button
  - Responsive: full-width on mobile (max 320px)
- `.language-selector__dropdown--open` - Modifier class to show dropdown

### Dropdown Items
- `.language-selector__item` - List item wrapper (minimum 44x44px)
- `.language-selector__link` - Language option link
  - Minimum 44x44px tap target (48px on mobile)
  - Hover and focus states
- `.language-selector__link--active` - Modifier for currently selected language

### Additional Elements
- `.language-selector__icon` - Icon styling within selector (20x20px)
- `.language-selector__separator` - Visual separator for dropdown sections

## Design System Integration
All classes use CSS custom properties from `design-tokens.css`:
- `--color-bg`, `--color-bg-secondary`, `--color-bg-tertiary`
- `--color-text`
- `--color-border`, `--color-border-secondary`
- `--color-primary`
- `--color-shadow`

## Usage Example

```html
<div class="language-selector">
  <button class="language-selector__button" aria-expanded="false">
    <span>English</span>
    <i class="language-selector__icon">▼</i>
  </button>
  
  <ul class="language-selector__dropdown">
    <li class="language-selector__item">
      <a href="?locale=en" class="language-selector__link language-selector__link--active">
        English
      </a>
    </li>
    <li class="language-selector__item">
      <a href="?locale=fr" class="language-selector__link">
        Français
      </a>
    </li>
    <li class="language-selector__item">
      <a href="?locale=es" class="language-selector__link">
        Español
      </a>
    </li>
  </ul>
</div>
```

## JavaScript Requirements
The CSS provides visual styling only. JavaScript is required to:
1. Toggle `.language-selector__dropdown--open` class on button click
2. Toggle `.language-selector__button--open` class on button click
3. Update `aria-expanded` attribute
4. Handle keyboard navigation (arrow keys, escape)
5. Close dropdown when clicking outside

## Accessibility Features
- ✅ Minimum 44x44px tap targets (desktop)
- ✅ Minimum 48x48px tap targets (mobile)
- ✅ Clear focus indicators (2px outline)
- ✅ High contrast using design system colors
- ✅ Semantic HTML support (button, list, links)
- ✅ Responsive design for mobile devices

## Related Files
- `app/assets/stylesheets/navigation.css` - CSS implementation
- `app/assets/stylesheets/design-tokens.css` - Color variables
- `test/e2e/language-switcher.test.js` - E2E tests

## Issue Reference
GitHub Issue #1094: Create CSS classes for language selector with mobile accessibility standards
