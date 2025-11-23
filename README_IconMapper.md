# Icon Mapping System

A dynamic JavaScript module for mapping search terms to relevant Font Awesome icons for the Yelp search demo application.

## Features

- **Category-based Icon Mapping**: Organizes icons into logical categories (coffee/cafe, food types, cuisines, restaurant types)
- **Intelligent Fallback System**: Provides contextual fallbacks for unmatched terms
- **Partial Matching**: Matches compound terms and partial matches
- **Font Awesome Integration**: Uses Font Awesome 6.1.1 icon library

## Categories

### Coffee/Cafe Icons
- `coffee`, `cafe`, `coffee shop`, `espresso`, `latte`, `cappuccino`, `starbucks`, `dunkin`
- Icon: `fas fa-coffee`

### Food Type Icons
- `pizza`, `pizzeria` → `fas fa-pizza-slice`
- `burgers`, `burger`, `fast food` → `fas fa-hamburger`
- `tacos`, `taco`, `sandwich`, `sandwiches` → `fas fa-utensils`
- `sushi`, `seafood`, `japanese` → `fas fa-fish`
- `bakery`, `dessert`, `ice cream`, `donuts`, `donut` → `fas fa-birthday-cake`

### Cuisine Icons
- `italian`, `chinese`, `mexican`, `korean`, `mediterranean`, `steakhouse` → `fas fa-utensils`
- `indian`, `vegan` → `fas fa-seedling`
- `thai`, `vegetarian` → `fas fa-leaf`
- `japanese` → `fas fa-fish`
- `french` → `fas fa-wine-glass`
- `american` → `fas fa-flag`
- `bbq`, `barbecue` → `fas fa-fire`

### Restaurant Type Icons
- `restaurant`, `restaurants`, `diner`, `buffet` → `fas fa-utensils`
- `bar`, `bars`, `french` → `fas fa-wine-glass`
- `pub`, `brewery` → `fas fa-beer`
- `fine dining` → `fas fa-bell`

## Usage

### Basic Usage

```javascript
import { getIcon } from './iconMapper.js';

// Direct matches
const coffeeIcon = getIcon('coffee'); // 'fas fa-coffee'
const pizzaIcon = getIcon('pizza'); // 'fas fa-pizza-slice'

// Partial matches
const coffeeShopIcon = getIcon('coffee shop'); // 'fas fa-coffee'
const fastFoodIcon = getIcon('fast food'); // 'fas fa-hamburger'

// Category-based fallbacks
const foodCourtIcon = getIcon('food court'); // 'fas fa-utensils' (food-related)
const juiceBarIcon = getIcon('juice bar'); // 'fas fa-glass' (drink-related)

// Default fallback
const unknownIcon = getIcon('unknown term'); // 'fas fa-map-marker-alt'
```

### Advanced Usage

```javascript
import { getIcon, getAllMappings, getCategories } from './iconMapper.js';

// Get all available mappings
const allMappings = getAllMappings();

// Get categories
const categories = getCategories(); // ['coffee', 'food', 'cuisine', 'restaurant']

// Create HTML icon element
function createIconElement(searchTerm) {
  const iconClass = getIcon(searchTerm);
  return `<i class="${iconClass}" aria-hidden="true"></i>`;
}

// Create icon with text
function createIconWithText(searchTerm) {
  const iconClass = getIcon(searchTerm);
  return `<i class="${iconClass}" aria-hidden="true"></i> ${searchTerm}`;
}
```

### Stimulus Controller Integration

```javascript
import { Controller } from '@hotwired/stimulus';
import { getIcon } from 'iconMapper';

export default class extends Controller {
  static targets = ['searchInput', 'iconDisplay'];

  updateIcon() {
    const searchTerm = this.searchInputTarget.value;
    const iconClass = getIcon(searchTerm);
    this.iconDisplayTarget.innerHTML = `<i class="${iconClass}" aria-hidden="true"></i>`;
  }
}
```

## Fallback System

The icon mapping system uses a sophisticated fallback hierarchy:

1. **Direct Match**: Exact match from the mappings
2. **Partial Match**: Searches for partial matches in compound terms
3. **Category Fallbacks**:
   - Food-related terms → `fas fa-utensils`
   - Drink-related terms → `fas fa-glass`
   - Restaurant-related terms → `fas fa-store`
4. **Default Fallback**: `fas fa-map-marker-alt`

## File Structure

```
app/javascript/
├── iconMapper.js          # Main icon mapping module
├── iconMapperExample.js   # Usage examples and helper functions
└── application.js         # Main application file
```

## Configuration

The module is configured in `config/importmap.rb`:

```ruby
pin 'iconMapper', to: 'iconMapper.js'
pin 'iconMapperExample', to: 'iconMapperExample.js'
```

## Font Awesome Dependency

The system requires Font Awesome 6.1.1, which is already configured in the project:

```ruby
pin '@fortawesome/fontawesome-free',
    to: 'https://ga.jspm.io/npm:@fortawesome/fontawesome-free@6.1.1/js/all.js'
```

## Extending the System

To add new icon mappings:

1. Add entries to the appropriate category object in `iconMapper.js`
2. Ensure the Font Awesome icon exists in version 6.1.1
3. Test the mapping using the example functions

Example:
```javascript
// Add to foodTypeIcons
const foodTypeIcons = {
  // ... existing mappings
  'new food type': 'fas fa-new-icon',
};
```

## Testing

Use the example file to test icon mappings:

```javascript
import './iconMapperExample.js';
// Check console for test output
```
