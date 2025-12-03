# Language Selector CSS Classes

## Overview
CSS classes for the language selector button and dropdown menu, implementing mobile-friendly tap targets and using existing design system color variables.

**Related Issue:** #1094  
**Part of:** #1092

## CSS Classes

### Container
- `.language-selector` - Main container wrapper (relative positioning for dropdown)

### Button
- `.language-selector__button` - Main button/pill element
  - Minimum 44x44px tap target (mobile accessibility)
  - Pill-shaped with rounded borders
  - Uses design tokens: `--color-bg-secondary`, `--color-text`, `--color-border`
  - Includes hover, focus, and active states
  
- `.language-selector__icon` - Optional icon within button (16x16px)

### Dropdown Menu
- `.language-selector__menu` - Dropdown container
  - Positioned absolutely below button with 8px gap
  - Safe spacing from viewport edges
  - Hidden by default
  - Uses design tokens for colors and shadows
  
- `.language-selector__menu--open` - Modifier to show dropdown
  - Apply this class to open the menu
  - Handles opacity and transform transitions

### Menu Items
- `.language-selector__menu-item` - Individual language option
  - Minimum 44x44px tap target (mobile accessibility)
  - Full-width for easy tapping
  - Hover and focus states included
  - Can be used on `<a>` or `<button>` elements
  
- `.language-selector__menu-item--active` - Current/active language
  - Uses `--color-primary` for highlighting
  - Bold font weight

## Usage Example

```html
<div class="language-selector">
  <button 
    class="language-selector__button" 
    aria-haspopup="true"
    aria-expanded="false"
  >
    <span class="language-selector__icon">🌐</span>
    English
  </button>
  
  <div class="language-selector__menu" role="menu">
    <a href="/en" class="language-selector__menu-item language-selector__menu-item--active" role="menuitem">
      English
    </a>
    <a href="/fr" class="language-selector__menu-item" role="menuitem">
      Français
    </a>
    <a href="/es" class="language-selector__menu-item" role="menuitem">
      Español
    </a>
    <a href="/pt-BR" class="language-selector__menu-item" role="menuitem">
      Português
    </a>
  </div>
</div>
```

## Accessibility Features

### Mobile Tap Targets
- Button: minimum 44x44px
- Menu items: minimum 44x44px height
- Full-width tap targets on narrow viewports

### Keyboard Navigation
- Focus states with visible outlines
- Works with keyboard navigation (Tab, Enter, Arrow keys via ARIA)

### Screen Readers
- Proper ARIA attributes (`aria-haspopup`, `role="menu"`, `role="menuitem"`)
- Semantic HTML structure

### Additional Accessibility
- High contrast mode support (thicker borders)
- Reduced motion support (disables transitions)
- Dark mode support via design tokens

## Design Tokens Used

### Colors
- `--color-bg` - Menu background
- `--color-bg-secondary` - Button background, item hover
- `--color-bg-tertiary` - Active/pressed states
- `--color-text` - Text color
- `--color-border` - Border colors
- `--color-border-secondary` - Hover border
- `--color-primary` - Active item highlight, focus outline
- `--color-shadow` - Menu shadow
- `--color-shadow-dark` - Dark mode menu shadow

## Responsive Behavior

### Mobile (≤768px)
- Enforces 44x44px minimum tap targets
- Full-width dropdown positioning
- Max-width constraint to prevent viewport overflow (32px margin)
- Increased padding on menu items (14px vs 12px)

### Tablet (≤1024px)
- 8px margin from viewport edge

### Desktop
- Standard styling as defined

## Browser Support
- Modern browsers with CSS custom properties support
- Graceful degradation for older browsers
- Tested with Safari, Chrome, Firefox, Edge

## JavaScript Integration
Toggle the `.language-selector__menu--open` class to show/hide the dropdown:

```javascript
const button = document.querySelector('.language-selector__button');
const menu = document.querySelector('.language-selector__menu');

button.addEventListener('click', () => {
  const isOpen = menu.classList.contains('language-selector__menu--open');
  menu.classList.toggle('language-selector__menu--open');
  button.setAttribute('aria-expanded', !isOpen);
});
```

## Testing
The CSS classes are compatible with the existing test selectors:
- `button[aria-haspopup]` - Language selector button
- `[role="menu"] a` - Menu items
- `.language-menu a` - Legacy selector (backwards compatible)

## Notes
- The `.language-menu` class is included for backwards compatibility with existing tests
- All transitions respect `prefers-reduced-motion` user preference
- Safe positioning ensures dropdown doesn't clip at screen edges
- Color variables automatically adapt to light/dark themes
