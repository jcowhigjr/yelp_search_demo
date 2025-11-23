# Dynamic Theme System Documentation

## Overview

The Dynamic Theme System extends theming beyond search functionality to create a cohesive, context-aware UI experience. When users search for different types of food or establishments, the entire interface adapts with appropriate colors, animations, and visual elements while maintaining brand consistency.

## Features

### 🎨 **Comprehensive UI Theming**
- **Navigation Bar**: Colors adapt to search context
- **Buttons**: Submit, clear, and action buttons match theme
- **Headers**: Page titles and section headers use theme colors
- **Containers**: Page containers get subtle theme accents
- **Footer**: Footer styling adapts to current theme
- **Forms**: Input fields and form elements use theme colors

### 🍕 **Contextual Themes**

#### Coffee Theme (`theme-coffee`)
- **Colors**: Warm browns, creams, and coffee tones
- **Special Effect**: Steam animation on search icon
- **Triggered by**: "coffee", "cafe", "espresso", "latte", etc.

#### Mexican Theme (`theme-mexican`)
- **Colors**: Vibrant oranges, yellows, and warm tones
- **Special Effect**: Spicy pulse animation on hover
- **Triggered by**: "taco", "mexican", "burrito", "quesadilla", etc.

#### Pizza Theme (`theme-pizza`)
- **Colors**: Rich reds and greens (Italian flag inspired)
- **Special Effect**: Pizza emoji appears on card hover
- **Triggered by**: "pizza", "pizzeria", "italian", etc.

#### Burger Theme (`theme-burger`)
- **Colors**: Bold oranges and golden yellows
- **Triggered by**: "burger", "hamburger", "fast food", etc.

#### Sushi Theme (`theme-sushi`)
- **Colors**: Calm greens and blues (zen-inspired)
- **Special Effect**: Subtle floating animation
- **Triggered by**: "sushi", "japanese", "ramen", "sake", etc.

#### Chinese Theme (`theme-chinese`)
- **Colors**: Lucky reds and golden yellows
- **Triggered by**: "chinese", "dim sum", "noodles", "wok", etc.

#### Thai Theme (`theme-thai`)
- **Colors**: Spicy pinks and fresh greens
- **Triggered by**: "thai", "pad thai", "curry", etc.

#### Indian Theme (`theme-indian`)
- **Colors**: Warm oranges and spice greens
- **Triggered by**: "indian", "curry", "tandoor", "biryani", etc.

#### Bar Theme (`theme-bar`)
- **Colors**: Deep purples and golden accents
- **Special Effect**: Cocktail glass animation in navbar
- **Triggered by**: "bar", "cocktail", "wine", "brewery", "pub", etc.

#### Dessert Theme (`theme-dessert`)
- **Colors**: Sweet pinks and pastel tones
- **Special Effect**: Sparkle animation
- **Triggered by**: "dessert", "ice cream", "bakery", "cake", "donut", etc.

#### Default Theme (`theme-default`)
- **Colors**: Classic blue tones
- **Fallback**: Used when no specific theme is detected

## Implementation

### HTML Structure

Add theme data attributes to elements you want to be themed:

```html
<!-- Main container -->
<body data-controller="theme" data-theme-target="container">

<!-- Navbar -->
<nav data-theme-target="navbar" data-themeable>

<!-- Buttons -->
<button data-theme-target="button" class="search-submit-btn">

<!-- Headers -->
<h2 data-theme-target="header">Search Results</h2>

<!-- Generic themeable elements -->
<div data-themeable>Content that should be themed</div>
```

### JavaScript Controller

The theme system is managed by the `ThemeController` Stimulus controller:

```javascript
// Manual theme change
const themeController = document.querySelector('[data-controller="theme"]');
if (themeController) {
  themeController.changeTheme('coffee', 'coffee shop');
}

// Listen for theme changes
document.addEventListener('theme:changed', (event) => {
  console.log('Theme changed to:', event.detail.theme);
});
```

### CSS Classes

Themes are applied through CSS classes:

```scss
.theme-coffee {
  .navbar { background-color: #8B4513; }
  .btn { background-color: #8B4513; }
  // ... other themed elements
}
```

## Usage Examples

### Automatic Theme Detection

The system automatically detects themes based on search input:

```javascript
// User types "tacos" → Mexican theme activates
// User types "sushi" → Sushi theme activates
// User types "coffee" → Coffee theme activates
```

### Manual Theme Control

```javascript
// Apply specific theme
ThemeDemo.testTheme('pizza');

// Start demo cycle
ThemeDemo.startDemo();

// Reset to default
ThemeDemo.resetToDefault();
```

### Search Integration

The theme system integrates with the search controller:

```javascript
// Search controller dispatches events
document.dispatchEvent(new CustomEvent('search:analyzed', {
  detail: { term: 'tacos', category: 'mexican' }
}));
```

## Configuration

### Theme Persistence

Themes are stored in localStorage and persist across sessions:

```javascript
// Themes persist for 24 hours
const themeData = {
  theme: 'coffee',
  searchTerm: 'coffee shop',
  timestamp: Date.now()
};
localStorage.setItem('currentUITheme', JSON.stringify(themeData));
```

### Responsive Design

Themes adapt to different screen sizes:

```scss
@media (max-width: 768px) {
  .theme-transitioning {
    transition-duration: 0.2s; // Faster on mobile
  }
  
  // Reduced animations for performance
  .theme-coffee .search-icon::after {
    display: none;
  }
}
```

### Accessibility

The system supports accessibility preferences:

```scss
// High contrast mode
@media (prefers-contrast: high) {
  .theme-coffee {
    border-width: 3px !important;
  }
}

// Reduced motion
@media (prefers-reduced-motion: reduce) {
  .theme-transitioning {
    animation: none !important;
    transition: none !important;
  }
}
```

## Brand Consistency

While themes change colors and effects, the system maintains brand consistency through:

1. **Typography**: Font families remain consistent
2. **Layout**: Spacing and positioning don't change
3. **Hierarchy**: Information hierarchy stays the same
4. **Usability**: Core functionality remains unchanged

## Performance

### Optimizations

- **CSS Variables**: Core colors defined as CSS custom properties
- **Smooth Transitions**: 0.3-0.4s transitions for pleasant UX
- **Mobile Performance**: Reduced animations on mobile devices
- **Lazy Loading**: Themes only apply when needed

### Browser Support

- **Modern Browsers**: Full support with all animations
- **Older Browsers**: Graceful degradation with basic color changes
- **Print Styles**: Themes disabled for printing

## Testing

### Demo Commands

Open browser console and try:

```javascript
// Start automatic theme cycling
ThemeDemo.startDemo();

// Test specific theme
ThemeDemo.testTheme('mexican');

// List all themes
ThemeDemo.listThemes();

// Get current theme
ThemeDemo.getCurrentThemeInfo();
```

### Manual Testing

1. Search for "coffee" → Should activate coffee theme
2. Search for "tacos" → Should activate Mexican theme
3. Search for "pizza" → Should activate pizza theme
4. Clear search → Should return to default theme

## Future Enhancements

### Potential Additions

1. **Seasonal Themes**: Holiday-specific themes
2. **User Preferences**: Allow users to set favorite themes
3. **Custom Themes**: User-defined color schemes
4. **Geographic Themes**: Themes based on location
5. **Time-based Themes**: Different themes for breakfast/lunch/dinner

### Integration Ideas

1. **Weather Integration**: Themes adapt to weather conditions
2. **Time of Day**: Morning coffee theme, evening bar theme
3. **User History**: Themes based on favorite cuisines
4. **Social Features**: Share favorite themed searches

## Troubleshooting

### Common Issues

1. **Theme Not Applying**: Check if theme controller is properly initialized
2. **Animations Not Working**: Verify CSS animations are enabled
3. **Performance Issues**: Disable animations on slower devices
4. **Theme Persistence**: Clear localStorage if themes get stuck

### Debug Commands

```javascript
// Check if controller exists
document.querySelector('[data-controller="theme"]');

// Get current theme
ThemeDemo.getCurrentThemeInfo();

// Reset all themes
document.body.className = document.body.className.replace(/theme-\w+/g, '');
```

## Conclusion

The Dynamic Theme System creates an engaging, contextual user experience that responds to user intent while maintaining usability and brand consistency. The system is designed to be extensible, performant, and accessible across all devices and user preferences.
