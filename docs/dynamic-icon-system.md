# Dynamic Icon System Documentation

The dynamic icon system provides intelligent icon mapping for search terms, enhancing user experience with contextual visual cues. This system supports both FontAwesome icons and emoji alternatives, with comprehensive accessibility features and theme customization.

## Table of Contents

1. [Adding New Icon Mappings](#adding-new-icon-mappings)
2. [Keyword Detection Logic](#keyword-detection-logic)
3. [Theme Customization](#theme-customization)
4. [Accessibility Guidelines](#accessibility-guidelines)
5. [Performance Considerations](#performance-considerations)
6. [Testing](#testing)

## Adding New Icon Mappings

### Basic Icon Mapping

To add new icon mappings, update the appropriate category in `app/javascript/iconMapper.js`:

```javascript
// Example: Adding new coffee-related terms
const coffeeIcons = {
  coffee: 'fas fa-coffee',
  cafe: 'fas fa-coffee',
  'coffee shop': 'fas fa-coffee',
  // Add new mappings here
  'cold brew': 'fas fa-coffee',
  'frappuccino': 'fas fa-coffee',
  'macchiato': 'fas fa-coffee'
};
```

### Category-Based Mapping

The system organizes icons into logical categories:

#### Food Type Icons
```javascript
const foodTypeIcons = {
  // Existing mappings...
  
  // Add new food types
  'ramen': 'fas fa-utensils',
  'pho': 'fas fa-utensils',
  'dim sum': 'fas fa-utensils',
  'tapas': 'fas fa-wine-glass'
};
```

#### Cuisine Type Icons
```javascript
const cuisineIcons = {
  // Existing mappings...
  
  // Add new cuisines
  'ethiopian': 'fas fa-utensils',
  'peruvian': 'fas fa-pepper-hot',
  'vietnamese': 'fas fa-leaf',
  'lebanese': 'fas fa-seedling'
};
```

#### Restaurant Type Icons
```javascript
const restaurantTypeIcons = {
  // Existing mappings...
  
  // Add new restaurant types
  'food truck': 'fas fa-truck',
  'food court': 'fas fa-utensils',
  'rooftop bar': 'fas fa-wine-glass',
  'speakeasy': 'fas fa-cocktail'
};
```

### Emoji Icon Sets

Add corresponding emoji icons for better visual diversity:

```javascript
const emojiIconSets = {
  // Existing sets...
  
  // Add new cuisine category
  mediterranean: {
    primary: '🫒', // olive
    alternatives: ['🫒', '🧄', '🍅'] // olive, garlic, tomato
  },
  
  seafood: {
    primary: '🦐', // shrimp
    alternatives: ['🦐', '🦀', '🐟'] // shrimp, crab, fish
  }
};
```

### Best Practices for New Mappings

1. **Consistency**: Use existing FontAwesome classes when possible
2. **Fallbacks**: Ensure all new categories have proper fallback icons
3. **Plurals**: The system automatically handles plurals, but add explicit mappings for irregular plurals
4. **Compound Terms**: Test with multi-word search terms
5. **Case Sensitivity**: All matching is case-insensitive

```javascript
// Example of comprehensive mapping addition
const newCuisineCategory = {
  // Direct mappings
  'ethiopian': 'fas fa-utensils',
  'ethiopian food': 'fas fa-utensils',
  'ethiopian restaurant': 'fas fa-utensils',
  
  // Handle variations
  'injera': 'fas fa-utensils',
  'berbere': 'fas fa-pepper-hot',
  
  // Emoji set
  ethiopian: {
    primary: '🍽️',
    alternatives: ['🍽️', '🥘', '🌶️']
  }
};
```

## Keyword Detection Logic

### Normalization Process

The system normalizes search terms through several steps:

1. **Case Conversion**: All terms converted to lowercase
2. **Whitespace Trimming**: Remove leading/trailing spaces
3. **Plural Handling**: Convert plurals to singular forms
4. **Special Character Handling**: Process hyphens, underscores, and other separators

```javascript
function normalizeSearchTerm(term) {
  if (!term) return '';
  
  let normalized = term.toLowerCase().trim();
  
  // Handle common plural forms
  const pluralMap = {
    'coffees': 'coffee',
    'cafes': 'cafe',
    // Add more irregular plurals here
  };
  
  // Check for direct plural mappings
  if (pluralMap[normalized]) {
    return pluralMap[normalized];
  }
  
  // Handle regular plural endings
  if (normalized.endsWith('s') && normalized.length > 3) {
    const singular = normalized.slice(0, -1);
    if (iconMappings[singular]) {
      return singular;
    }
  }
  
  return normalized;
}
```

### Matching Algorithm

The system uses a multi-tier matching approach:

#### 1. Direct Matching
```javascript
// Exact match after normalization
if (iconMappings[normalized]) {
  return iconMappings[normalized];
}
```

#### 2. Word-Level Matching
```javascript
// Split compound terms and check each word
const words = normalized.split(/[\s-_]+/);
for (const word of words) {
  const normalizedWord = normalizeSearchTerm(word);
  if (iconMappings[normalizedWord]) {
    return iconMappings[normalizedWord];
  }
}
```

#### 3. Fuzzy Matching with Scoring
```javascript
function calculateMatchScore(searchTerm, keyword) {
  // Exact match
  if (searchTerm === keyword) return 1.0;
  
  // Contains match
  if (searchTerm.includes(keyword)) return 0.8;
  if (keyword.includes(searchTerm)) return 0.7;
  
  // Word boundary matches
  const searchWords = searchTerm.split(/[\s-_]+/);
  const keywordWords = keyword.split(/[\s-_]+/);
  
  let matchingWords = 0;
  for (const searchWord of searchWords) {
    for (const keywordWord of keywordWords) {
      if (searchWord === keywordWord || 
          searchWord.includes(keywordWord) || 
          keywordWord.includes(searchWord)) {
        matchingWords++;
        break;
      }
    }
  }
  
  return matchingWords / Math.max(searchWords.length, keywordWords.length);
}
```

#### 4. Category-Based Fallbacks
```javascript
// If no specific match found, use category detection
if (isFoodRelated(normalizedTerm)) {
  return fallbackIcons.food;
}

if (isDrinkRelated(normalizedTerm)) {
  return fallbackIcons.drink;
}

if (isRestaurantRelated(normalizedTerm)) {
  return fallbackIcons.restaurant;
}
```

### Adding Custom Detection Logic

To add new keyword detection categories:

```javascript
// 1. Create keyword array
function isNewCategoryRelated(term) {
  const newCategoryKeywords = ['keyword1', 'keyword2', 'keyword3'];
  return newCategoryKeywords.some(keyword => term.includes(keyword));
}

// 2. Add to main analysis function
function analyzeSearchTerm(searchTerm) {
  // ... existing logic ...
  
  if (isNewCategoryRelated(normalizedTerm)) {
    return 'fas fa-new-category-icon';
  }
  
  // ... fallback logic ...
}

// 3. Add emoji detection
function getEmojiIcon(term, iconType = 'primary') {
  // ... existing logic ...
  
  if (isNewCategoryRelated(normalizedTerm)) {
    return getIconFromSet(emojiIconSets.newCategory, iconType);
  }
  
  // ... fallback logic ...
}
```

## Theme Customization

### CSS Theme Classes

The system applies theme classes based on detected categories:

```css
/* Coffee theme */
.theme-coffee {
  --primary-color: #8B4513;
  --accent-color: #D2691E;
  --icon-color: #654321;
}

/* Food theme */
.theme-food {
  --primary-color: #FF6347;
  --accent-color: #FFA500;
  --icon-color: #FF4500;
}

/* Restaurant theme */
.theme-restaurant {
  --primary-color: #DAA520;
  --accent-color: #FFD700;
  --icon-color: #B8860B;
}

/* Default theme */
.theme-default {
  --primary-color: #2C3E50;
  --accent-color: #3498DB;
  --icon-color: #34495E;
}
```

### Theme Application

```javascript
// Automatic theme application
export function applyThemeForSearchTerm(element, searchTerm) {
  if (!element || !searchTerm) return;
  
  // Remove existing theme classes
  element.classList.remove('theme-coffee', 'theme-food', 'theme-restaurant', 'theme-default');
  
  // Determine theme based on search term
  const normalizedTerm = normalizeSearchTerm(searchTerm);
  let themeClass = 'theme-default';
  
  if (isCoffeeRelated(normalizedTerm)) {
    themeClass = 'theme-coffee';
  } else if (isFoodRelated(normalizedTerm)) {
    themeClass = 'theme-food';
  } else if (isRestaurantRelated(normalizedTerm)) {
    themeClass = 'theme-restaurant';
  }
  
  // Apply theme
  element.classList.add(themeClass);
  
  // Store for cross-page consistency
  const searchData = {
    term: searchTerm,
    category: themeClass.replace('theme-', ''),
    timestamp: Date.now()
  };
  
  localStorage.setItem('lastSearchData', JSON.stringify(searchData));
}
```

### Cross-Page Theme Persistence

```javascript
// Initialize theme on page load
export function initializePageTheme() {
  document.addEventListener('DOMContentLoaded', () => {
    const themeElements = document.querySelectorAll('[data-search-theme]');
    themeElements.forEach(element => {
      applyStoredTheme(element);
    });
  });
}

// Apply stored theme
export function applyStoredTheme(element) {
  const searchData = getStoredSearchData();
  if (searchData && element) {
    // Remove existing theme classes
    element.classList.remove('theme-coffee', 'theme-food', 'theme-restaurant', 'theme-default');
    // Apply stored theme
    element.classList.add(`theme-${searchData.category}`);
    return searchData;
  }
  return null;
}
```

### Custom Theme Creation

To create new themes:

1. **Define CSS Variables**:
```css
.theme-custom {
  --primary-color: #YOUR_PRIMARY;
  --accent-color: #YOUR_ACCENT;
  --icon-color: #YOUR_ICON_COLOR;
  --background-gradient: linear-gradient(45deg, #START, #END);
}
```

2. **Add Theme Detection Logic**:
```javascript
function isCustomThemeRelated(term) {
  const customKeywords = ['custom1', 'custom2'];
  return customKeywords.some(keyword => term.includes(keyword));
}
```

3. **Update Theme Application**:
```javascript
// In applyThemeForSearchTerm function
if (isCustomThemeRelated(normalizedTerm)) {
  themeClass = 'theme-custom';
}
```

## Accessibility Guidelines

### Screen Reader Support

#### Icon Hiding
All decorative icons must have `aria-hidden="true"`:

```html
<!-- Correct -->
<i class="fas fa-coffee" aria-hidden="true"></i>

<!-- Incorrect -->
<i class="fas fa-coffee"></i>
```

#### Meaningful Labels
Interactive elements with icons need descriptive labels:

```html
<!-- Submit button with icon -->
<button type="submit" aria-label="Search for coffee shops">
  <i class="fas fa-coffee" aria-hidden="true"></i>
  Search
</button>
```

#### Dynamic Label Updates
Update aria-labels when icons change:

```javascript
function updateSubmitButtonLabel(searchTerm, iconClass) {
  const submitButton = document.querySelector('[data-search-target="submitButton"]');
  const submitIcon = document.querySelector('[data-search-target="submitIcon"]');
  
  if (submitIcon && searchTerm) {
    const category = getCategoryFromIcon(iconClass);
    const label = `Search for ${searchTerm} ${category}`;
    submitIcon.setAttribute('aria-label', label);
  }
}
```

### Keyboard Navigation

#### Focus Management
Icons should not interfere with keyboard navigation:

```css
/* Icons should not be focusable */
.search-icon i {
  pointer-events: none;
  user-select: none;
}

/* Focus should remain on input */
.search-input:focus {
  outline: 2px solid var(--accent-color);
  outline-offset: 2px;
}
```

#### Tab Order
Maintain logical tab order:
1. Search input
2. Submit button
3. Other interactive elements

### High Contrast Mode

#### Color Independence
Icons must be distinguishable without color:

```css
/* Use different shapes, not just colors */
.fa-coffee::before { content: "\f0f4"; }
.fa-pizza-slice::before { content: "\f818"; }
.fa-hamburger::before { content: "\f805"; }

/* High contrast support */
@media (prefers-contrast: high) {
  .search-icon i {
    filter: contrast(2);
    stroke: currentColor;
    stroke-width: 1px;
  }
}
```

### Reduced Motion

#### Animation Preferences
Respect user's motion preferences:

```css
/* Default smooth transitions */
.search-icon i {
  transition: all 0.3s ease;
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  .search-icon i {
    transition: none;
  }
}
```

### Mobile Accessibility

#### Touch Targets
Ensure adequate touch target sizes:

```css
/* Minimum 44px touch targets */
.search-submit-button {
  min-height: 44px;
  min-width: 44px;
  padding: 12px;
}
```

#### Screen Reader Announcements
Provide clear context for mobile screen readers:

```javascript
function announceIconChange(newIcon, searchTerm) {
  // Create announcement for screen readers
  const announcement = document.createElement('div');
  announcement.setAttribute('aria-live', 'polite');
  announcement.setAttribute('aria-atomic', 'true');
  announcement.className = 'sr-only';
  announcement.textContent = `Icon updated to ${getIconDescription(newIcon)} for ${searchTerm}`;
  
  document.body.appendChild(announcement);
  
  // Clean up after announcement
  setTimeout(() => {
    document.body.removeChild(announcement);
  }, 1000);
}
```

### Color Blind Accessibility

#### Sufficient Contrast
Ensure proper color contrast ratios:

```css
/* WCAG AA compliance (4.5:1 ratio) */
.theme-coffee {
  --primary-color: #4A2C2A; /* Dark enough for white text */
  --accent-color: #8B4513;  /* Sufficient contrast */
}

/* Test with various color blindness types */
.theme-food {
  --primary-color: #B22222; /* Distinguishable in protanopia */
  --accent-color: #FF4500;  /* Clear in deuteranopia */
}
```

### Testing Accessibility

Use the comprehensive test suite in `test/system/icon_accessibility_test.rb`:

```ruby
# Run accessibility tests
rails test test/system/icon_accessibility_test.rb

# Test specific scenarios
rails test test/system/icon_accessibility_test.rb::IconAccessibilityTest#test_screen_reader_announcements_work_properly
```

Key accessibility test categories:
- Screen reader compatibility
- Keyboard navigation
- High contrast mode
- Reduced motion preferences
- Voice control compatibility
- Mobile screen reader support
- Color blind accessibility

## Performance Considerations

### Debouncing
The system includes debouncing to prevent excessive updates:

```javascript
// Debounce icon updates
let iconUpdateTimeout;
function debounceIconUpdate(searchTerm) {
  clearTimeout(iconUpdateTimeout);
  iconUpdateTimeout = setTimeout(() => {
    updateIcon(searchTerm);
  }, 300); // 300ms debounce
}
```

### Memory Management
- Icon mappings are cached for performance
- Event listeners are properly cleaned up
- DOM updates are batched when possible

### Performance Testing
Run performance tests to ensure optimal behavior:

```bash
# Run performance test suite
rails test test/system/icon_performance_test.rb

# Test specific performance scenarios
rails test test/system/icon_performance_test.rb::IconPerformanceTest#test_handles_rapid_typing_without_performance_degradation
```

## Testing

### Running Tests

```bash
# Run all icon-related tests
bin/test_icon_suite

# Run specific test files
rails test test/javascript/icon_mapper_test.js
rails test test/system/icon_accessibility_test.rb
rails test test/system/icon_performance_test.rb
```

### Test Categories

1. **Keyword Mapping Tests**: Verify all keyword-to-icon mappings
2. **Accessibility Tests**: Ensure WCAG compliance
3. **Performance Tests**: Check system behavior under load
4. **Edge Case Tests**: Handle special characters, long terms, etc.

### Adding New Tests

When adding new icon mappings, include corresponding tests:

```javascript
// Add to test/javascript/icon_mapper_test.js
test('maps new cuisine keywords correctly', () => {
  const newCuisineMappings = {
    'ethiopian': 'fas fa-utensils',
    'peruvian': 'fas fa-pepper-hot'
  };
  
  Object.entries(newCuisineMappings).forEach(([keyword, expectedIcon]) => {
    expect(getIcon(keyword)).toBe(expectedIcon);
  });
});
```

## Troubleshooting

### Common Issues

1. **Icons not updating**: Check debounce timing and event listeners
2. **Accessibility violations**: Run accessibility test suite
3. **Performance degradation**: Monitor with performance tests
4. **Theme not persisting**: Verify localStorage implementation

### Debugging Tools

```javascript
// Debug icon mapping
console.log('All mappings:', getAllMappings());
console.log('Categories:', getCategories());
console.log('Icon for term:', getIcon('your-term'));

// Debug emoji system
console.log('Emoji sets:', getEmojiIconSets());
console.log('Category emojis:', getCategoryEmojis('coffee'));
```

## Contributing

When contributing to the icon system:

1. Add comprehensive tests for new mappings
2. Follow accessibility guidelines
3. Update documentation
4. Test with screen readers
5. Verify performance impact
6. Include emoji alternatives

## API Reference

### Core Functions

- `getIcon(term)`: Get FontAwesome icon class for term
- `getEmojiIcon(term, iconType)`: Get emoji icon for term
- `getAllMappings()`: Get all icon mappings
- `getCategories()`: Get available categories
- `getCategoryEmojis(category)`: Get emojis for category

### Utility Functions

- `normalizeSearchTerm(term)`: Normalize search term
- `analyzeSearchTerm(term)`: Advanced keyword analysis
- `calculateMatchScore(searchTerm, keyword)`: Calculate match score
- `applyThemeForSearchTerm(element, term)`: Apply theme based on term

---

This documentation provides a comprehensive guide to understanding, extending, and maintaining the dynamic icon system. For additional support or questions, refer to the test files for practical examples and implementation details.
