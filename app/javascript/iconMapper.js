// iconMapper.js - Dynamic icon mapping system for search terms

// Coffee and Cafe icons
const coffeeIcons = {
  coffee: 'fas fa-coffee',
  cafe: 'fas fa-coffee',
  'coffee shop': 'fas fa-coffee',
  espresso: 'fas fa-coffee',
  latte: 'fas fa-coffee',
  cappuccino: 'fas fa-coffee',
  starbucks: 'fas fa-coffee',
  'dunkin': 'fas fa-coffee'
};

// Food type icons
const foodTypeIcons = {
  tacos: 'fas fa-utensils', // fa-taco-hard not available, using utensils
  taco: 'fas fa-utensils',
  pizza: 'fas fa-pizza-slice',
  pizzeria: 'fas fa-pizza-slice',
  burgers: 'fas fa-hamburger',
  burger: 'fas fa-hamburger',
  'fast food': 'fas fa-hamburger',
  sandwich: 'fas fa-utensils', // fa-bread-slice not available
  sandwiches: 'fas fa-utensils',
  sushi: 'fas fa-fish',
  seafood: 'fas fa-fish',
  bakery: 'fas fa-birthday-cake', // fa-bread-loaf not available
  dessert: 'fas fa-birthday-cake', // fa-ice-cream not available
  'ice cream': 'fas fa-birthday-cake',
  donuts: 'fas fa-birthday-cake', // fa-donut not available
  donut: 'fas fa-birthday-cake'
};

// Cuisine type icons
const cuisineIcons = {
  italian: 'fas fa-utensils',
  chinese: 'fas fa-utensils', // fa-bowl-rice not available
  mexican: 'fas fa-utensils', // fa-pepper-hot not available
  indian: 'fas fa-seedling',
  thai: 'fas fa-leaf',
  japanese: 'fas fa-fish',
  korean: 'fas fa-utensils', // fa-bowl-hot not available
  french: 'fas fa-wine-glass',
  mediterranean: 'fas fa-utensils', // fa-olive not available
  american: 'fas fa-flag', // fa-flag-usa not available
  bbq: 'fas fa-fire',
  barbecue: 'fas fa-fire',
  steakhouse: 'fas fa-utensils', // fa-drumstick-bite not available
  vegetarian: 'fas fa-leaf',
  vegan: 'fas fa-seedling'
};

// Restaurant types
const restaurantTypeIcons = {
  restaurant: 'fas fa-utensils',
  restaurants: 'fas fa-utensils',
  bar: 'fas fa-wine-glass',
  bars: 'fas fa-wine-glass',
  pub: 'fas fa-beer',
  brewery: 'fas fa-beer',
  diner: 'fas fa-utensils', // fa-plate-wheat not available
  'fine dining': 'fas fa-bell', // fa-concierge-bell not available
  buffet: 'fas fa-utensils'
};

// Combine all icon mappings
const iconMappings = {
  ...coffeeIcons,
  ...foodTypeIcons,
  ...cuisineIcons,
  ...restaurantTypeIcons
};

// Fallback icons for different categories
const fallbackIcons = {
  food: 'fas fa-utensils',
  drink: 'fas fa-glass',
  restaurant: 'fas fa-store',
  default: 'fas fa-map-marker-alt'
};

/**
 * Normalize search term to handle plurals and variations
 * @param {string} term - The search term
 * @returns {string} - Normalized term
 */
function normalizeSearchTerm(term) {
  if (!term) return '';
  
  let normalized = term.toLowerCase().trim();
  
  // Handle common plural forms
  const pluralMap = {
    'coffees': 'coffee',
    'cafes': 'cafe',
    'lattes': 'latte',
    'cappuccinos': 'cappuccino',
    'espressos': 'espresso',
    'tacos': 'taco',
    'pizzas': 'pizza',
    'burgers': 'burger',
    'sandwiches': 'sandwich',
    'donuts': 'donut',
    'restaurants': 'restaurant',
    'bars': 'bar',
    'breweries': 'brewery',
    'bakeries': 'bakery'
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
  
  // Handle 'ies' endings (e.g., bakeries -> bakery)
  if (normalized.endsWith('ies') && normalized.length > 4) {
    const singular = normalized.slice(0, -3) + 'y';
    if (iconMappings[singular]) {
      return singular;
    }
  }
  
  return normalized;
}

/**
 * Advanced keyword matching algorithm
 * @param {string} searchTerm - The search term to analyze
 * @returns {string} - The best matching icon class
 */
function analyzeSearchTerm(searchTerm) {
  const normalized = normalizeSearchTerm(searchTerm);
  
  // Direct match after normalization
  if (iconMappings[normalized]) {
    return iconMappings[normalized];
  }
  
  // Split compound terms and check each word
  const words = normalized.split(/[\s-_]+/);
  for (const word of words) {
    const normalizedWord = normalizeSearchTerm(word);
    if (iconMappings[normalizedWord]) {
      return iconMappings[normalizedWord];
    }
  }
  
  // Partial matches with scoring
  let bestMatch = null;
  let bestScore = 0;
  
  for (const [key, icon] of Object.entries(iconMappings)) {
    const score = calculateMatchScore(normalized, key);
    if (score > bestScore) {
      bestScore = score;
      bestMatch = icon;
    }
  }
  
  if (bestMatch && bestScore > 0.3) {
    return bestMatch;
  }
  
  return null; // No good match found
}

/**
 * Calculate match score between search term and keyword
 * @param {string} searchTerm - The search term
 * @param {string} keyword - The keyword to match against
 * @returns {number} - Match score between 0 and 1
 */
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

/**
 * Get icon class for a given search term with intelligent fallbacks
 * @param {string} term - The search term
 * @returns {string} - The Font Awesome icon class
 */
export function getIcon(term) {
  if (!term) return fallbackIcons.default;
  
  // Use advanced analysis
  const analyzedIcon = analyzeSearchTerm(term);
  if (analyzedIcon) {
    return analyzedIcon;
  }
  
  const normalizedTerm = normalizeSearchTerm(term);
  
  // Category-based fallbacks
  if (isFoodRelated(normalizedTerm)) {
    return fallbackIcons.food;
  }
  
  if (isDrinkRelated(normalizedTerm)) {
    return fallbackIcons.drink;
  }
  
  if (isRestaurantRelated(normalizedTerm)) {
    return fallbackIcons.restaurant;
  }
  
  // Default fallback
  return fallbackIcons.default;
}

/**
 * Check if term is food-related
 * @param {string} term - The search term
 * @returns {boolean}
 */
function isFoodRelated(term) {
  const foodKeywords = ['food', 'eat', 'dining', 'meal', 'cuisine', 'kitchen', 'grill'];
  return foodKeywords.some(keyword => term.includes(keyword));
}

/**
 * Check if term is drink-related
 * @param {string} term - The search term
 * @returns {boolean}
 */
function isDrinkRelated(term) {
  const drinkKeywords = ['drink', 'beverage', 'juice', 'smoothie', 'tea', 'wine', 'beer', 'cocktail'];
  return drinkKeywords.some(keyword => term.includes(keyword));
}

/**
 * Check if term is restaurant-related
 * @param {string} term - The search term
 * @returns {boolean}
 */
function isRestaurantRelated(term) {
  const restaurantKeywords = ['restaurant', 'eatery', 'bistro', 'cafe', 'diner', 'place', 'spot'];
  return restaurantKeywords.some(keyword => term.includes(keyword));
}

/**
 * Get all available icon mappings (useful for debugging or UI)
 * @returns {Object} - All icon mappings
 */
export function getAllMappings() {
  return iconMappings;
}

/**
 * Get available categories
 * @returns {Array} - List of categories
 */
export function getCategories() {
  return ['coffee', 'food', 'cuisine', 'restaurant'];
}
