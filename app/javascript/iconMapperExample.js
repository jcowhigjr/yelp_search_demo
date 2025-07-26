// iconMapperExample.js - Usage examples for the icon mapping system

import { getIcon, getAllMappings, getCategories } from 'iconMapper';

// Example usage of the icon mapping system
console.log('Icon Mapping System Examples:');
console.log('============================');

// Direct matches
console.log('Direct matches:');
console.log(`Coffee: ${getIcon('coffee')}`); // fas fa-coffee
console.log(`Pizza: ${getIcon('pizza')}`); // fas fa-pizza-slice
console.log(`Italian: ${getIcon('italian')}`); // fas fa-utensils

// Partial matches
console.log('\nPartial matches:');
console.log(`Coffee shop: ${getIcon('coffee shop')}`); // fas fa-coffee
console.log(`Fast food: ${getIcon('fast food')}`); // fas fa-hamburger

// Category-based fallbacks
console.log('\nCategory-based fallbacks:');
console.log(`Food court: ${getIcon('food court')}`); // fas fa-utensils (food-related)
console.log(`Juice bar: ${getIcon('juice bar')}`); // fas fa-glass (drink-related)
console.log(`Local eatery: ${getIcon('local eatery')}`); // fas fa-store (restaurant-related)

// Default fallback
console.log('\nDefault fallback:');
console.log(`Random term: ${getIcon('random term')}`); // fas fa-map-marker-alt

// Get all mappings
console.log('\nAll mappings:', getAllMappings());

// Get categories
console.log('\nCategories:', getCategories());

// Function to create icon HTML element
export function createIconElement(searchTerm) {
  const iconClass = getIcon(searchTerm);
  return `<i class="${iconClass}" aria-hidden="true"></i>`;
}

// Function to create icon with text
export function createIconWithText(searchTerm) {
  const iconClass = getIcon(searchTerm);
  return `<i class="${iconClass}" aria-hidden="true"></i> ${searchTerm}`;
}

// Example for Stimulus controller usage
export function updateIconForSearchTerm(element, searchTerm) {
  const iconClass = getIcon(searchTerm);
  const iconElement = element.querySelector('i') || document.createElement('i');
  iconElement.className = iconClass;
  iconElement.setAttribute('aria-hidden', 'true');
  
  if (!element.querySelector('i')) {
    element.prepend(iconElement);
  }
}

// Cross-page theme consistency utilities
export function getStoredSearchData() {
  try {
    const storedData = localStorage.getItem('lastSearchData');
    if (storedData) {
      const searchData = JSON.parse(storedData);
      const twentyFourHours = 24 * 60 * 60 * 1000;
      
      // Return data only if it's recent (within 24 hours)
      if (Date.now() - searchData.timestamp < twentyFourHours) {
        return searchData;
      }
    }
  } catch (error) {
    console.warn('Failed to retrieve stored search data:', error);
  }
  return null;
}

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

export function clearStoredTheme() {
  localStorage.removeItem('lastSearchData');
  sessionStorage.removeItem('currentSearchTerm');
}

// Initialize theme on page load for consistent theming
export function initializePageTheme() {
  document.addEventListener('DOMContentLoaded', () => {
    const themeElements = document.querySelectorAll('[data-search-theme]');
    themeElements.forEach(element => {
      applyStoredTheme(element);
    });
  });
}
