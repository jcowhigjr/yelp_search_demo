# Dynamic Icon System - Quick Reference

This is a condensed reference guide for common tasks with the dynamic icon system. For comprehensive documentation, see [dynamic-icon-system.md](dynamic-icon-system.md).

## Quick Setup

### Adding a New Food Category

```javascript
// In app/javascript/iconMapper.js

// 1. Add to foodTypeIcons
const foodTypeIcons = {
  // ... existing mappings
  'pho': 'fas fa-utensils',
  'ramen': 'fas fa-utensils',
  'noodles': 'fas fa-utensils'
};

// 2. Add emoji set
const emojiIconSets = {
  // ... existing sets
  noodles: {
    primary: '🍜',
    alternatives: ['🍜', '🥢', '🍲']
  }
};

// 3. Add detection function
function isNoodleRelated(term) {
  const noodleKeywords = ['pho', 'ramen', 'noodle', 'udon', 'soba'];
  return noodleKeywords.some(keyword => term.includes(keyword));
}

// 4. Update getEmojiIcon function
export function getEmojiIcon(term, iconType = 'primary') {
  // ... existing logic
  if (isNoodleRelated(normalizedTerm)) {
    return getIconFromSet(emojiIconSets.noodles, iconType);
  }
  // ... rest of function
}
```

### Adding a Custom Theme

```css
/* In your CSS file */
.theme-noodles {
  --primary-color: #FF6B35;
  --accent-color: #F7931E;
  --icon-color: #C5282F;
  --background-gradient: linear-gradient(45deg, #FF6B35, #F7931E);
}
```

```javascript
// In theme application logic
function applyThemeForSearchTerm(element, searchTerm) {
  // ... existing logic
  if (isNoodleRelated(normalizedTerm)) {
    themeClass = 'theme-noodles';
  }
  // ... rest of function
}
```

## Common Code Patterns

### Basic Icon Usage

```html
<!-- In your view -->
<div class="search-container">
  <input type="text" data-search-target="input" />
  <div data-search-target="icon">
    <i class="fas fa-map-marker-alt" aria-hidden="true"></i>
  </div>
  <button type="submit" data-search-target="submitButton">
    <i data-search-target="submitIcon" aria-label="Search"></i>
  </button>
</div>
```

### JavaScript Implementation

```javascript
// Basic icon update
import { getIcon } from 'iconMapper';

function updateIcon(searchTerm) {
  const iconElement = document.querySelector('[data-search-target="icon"] i');
  const newIconClass = getIcon(searchTerm);
  iconElement.className = newIconClass;
  iconElement.setAttribute('aria-hidden', 'true');
}

// With debouncing
let iconUpdateTimeout;
function debounceIconUpdate(searchTerm) {
  clearTimeout(iconUpdateTimeout);
  iconUpdateTimeout = setTimeout(() => {
    updateIcon(searchTerm);
  }, 300);
}
```

### Stimulus Controller Pattern

```javascript
// search_controller.js
import { Controller } from "@hotwired/stimulus"
import { getIcon, getEmojiIcon } from "iconMapper"

export default class extends Controller {
  static targets = ["input", "icon", "submitIcon"]
  
  connect() {
    this.debounceTimeout = null;
  }
  
  inputChanged() {
    clearTimeout(this.debounceTimeout);
    this.debounceTimeout = setTimeout(() => {
      this.updateIcon();
    }, 300);
  }
  
  updateIcon() {
    const searchTerm = this.inputTarget.value;
    const iconClass = getIcon(searchTerm);
    
    // Update main icon
    const iconElement = this.iconTarget.querySelector('i');
    iconElement.className = iconClass;
    iconElement.setAttribute('aria-hidden', 'true');
    
    // Update submit button aria-label
    const category = this.getCategoryFromIcon(iconClass);
    this.submitIconTarget.setAttribute('aria-label', 
      `Search for ${searchTerm} ${category}`
    );
    
    // Apply theme
    this.applyTheme(searchTerm);
  }
  
  getCategoryFromIcon(iconClass) {
    if (iconClass.includes('fa-coffee')) return 'coffee shops';
    if (iconClass.includes('fa-pizza')) return 'pizza places';
    if (iconClass.includes('fa-hamburger')) return 'burger restaurants';
    return 'restaurants';
  }
  
  applyTheme(searchTerm) {
    // Remove existing themes
    this.element.classList.remove('theme-coffee', 'theme-food', 'theme-default');
    
    // Apply new theme based on search term
    const theme = this.getThemeForTerm(searchTerm);
    this.element.classList.add(theme);
  }
}
```

## Testing Checklist

When adding new mappings, verify:

```javascript
// Test your new mappings
console.log(getIcon('pho')); // Should return 'fas fa-utensils'
console.log(getEmojiIcon('ramen')); // Should return '🍜'

// Test plurals
console.log(getIcon('noodles')); // Should work same as 'noodle'

// Test compound terms
console.log(getIcon('pho restaurant')); // Should return 'fas fa-utensils'
```

### Accessibility Checklist

- ✅ All decorative icons have `aria-hidden="true"`
- ✅ Interactive elements have meaningful `aria-label`
- ✅ Icons don't interfere with keyboard navigation
- ✅ Sufficient color contrast (4.5:1 ratio)
- ✅ Works without color (high contrast mode)
- ✅ Respects reduced motion preferences

### Run Tests

```bash
# Quick test
bin/test_icon_suite

# Specific tests
rails test test/javascript/icon_mapper_test.js
rails test test/system/icon_accessibility_test.rb
```

## Debugging Commands

```javascript
// In browser console
import { getAllMappings, getCategories, getIcon } from 'iconMapper';

// See all mappings
console.table(getAllMappings());

// Test specific term
console.log('Icon for "sushi":', getIcon('sushi'));

// See all categories
console.log('Categories:', getCategories());

// Debug normalization
console.log('Normalized "COFFEE SHOPS":', normalizeSearchTerm('COFFEE SHOPS'));
```

## Performance Tips

1. **Debounce Updates**: Always debounce rapid input changes (300ms recommended)
2. **Cache Results**: Icon mappings are already cached, don't re-process
3. **Batch DOM Updates**: Update multiple elements in single operation
4. **Clean Event Listeners**: Remove listeners when components unmount

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Icons not updating | Check event listeners and debounce timing |
| Wrong icon shown | Verify keyword mappings and normalization |
| Accessibility violations | Run test suite, check aria attributes |
| Theme not applying | Verify CSS classes and localStorage |
| Performance issues | Check debouncing and memory usage |

## File Locations

- **Main Logic**: `app/javascript/iconMapper.js`
- **Examples**: `app/javascript/iconMapperExample.js`  
- **Tests**: `test/javascript/icon_mapper_test.js`
- **Accessibility Tests**: `test/system/icon_accessibility_test.rb`
- **Performance Tests**: `test/system/icon_performance_test.rb`
- **Test Runner**: `bin/test_icon_suite`

## API Quick Reference

```javascript
// Core functions
getIcon(term)                    // Returns FontAwesome class
getEmojiIcon(term, type)        // Returns emoji icon
getAllMappings()                // Returns all mappings object
getCategories()                 // Returns category array
getCategoryEmojis(category)     // Returns emojis for category

// Utility functions  
normalizeSearchTerm(term)       // Normalize term for matching
analyzeSearchTerm(term)         // Advanced keyword analysis
calculateMatchScore(a, b)       // Calculate match score (0-1)

// Theme functions
applyThemeForSearchTerm(el, term)  // Apply theme to element
getStoredSearchData()              // Get stored theme data
clearStoredTheme()                 // Clear stored theme
```

For complete documentation with examples and advanced usage, see [dynamic-icon-system.md](dynamic-icon-system.md).
