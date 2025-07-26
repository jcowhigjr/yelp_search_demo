import { Controller } from '@hotwired/stimulus';
import { getIcon, getAllMappings } from '../iconMapper';

export default class extends Controller {
  static targets = ['input', 'icon', 'theme', 'submitButton', 'submitIcon'];
  static values = { debounceDelay: { type: Number, default: 300 } };

  connect() {
    this.lastSearchTerm = '';
    this.debounceTimer = null;
    
    // Set up real-time input analysis
    this.inputTarget.addEventListener('input', this.handleInput.bind(this));
    this.inputTarget.addEventListener('focus', this.handleFocus.bind(this));
    this.inputTarget.addEventListener('blur', this.handleBlur.bind(this));
    
    // Load previously stored search term for consistent theming
    this.loadStoredTheme();
  }

  disconnect() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
    }
  }

  /**
   * Handle real-time input with debouncing
   */
  handleInput() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
    }
    
    this.debounceTimer = setTimeout(() => {
      this.analyzeSearchTerm();
    }, this.debounceDelayValue);
  }

  /**
   * Handle input focus - show real-time feedback
   */
  handleFocus() {
    this.element.classList.add('search-focused');
    if (this.hasIconTarget) {
      this.iconTarget.classList.add('icon-active');
    }
  }

  /**
   * Handle input blur - maintain theme consistency
   */
  handleBlur() {
    this.element.classList.remove('search-focused');
    if (this.hasIconTarget) {
      this.iconTarget.classList.remove('icon-active');
    }
  }

  /**
   * Analyze search term in real-time
   */
  analyzeSearchTerm() {
    const searchTerm = this.inputTarget.value.trim();
    
    if (searchTerm !== this.lastSearchTerm) {
      this.lastSearchTerm = searchTerm;
      
      // Update icon based on detected keywords
      this.updateIconForTerm(searchTerm);
      
      // Update submit button icon contextually
      this.updateSubmitIcon(searchTerm);
      
      // Apply consistent theming
      this.applyTheme(searchTerm);
      
      // Store for cross-page consistency
      this.storeSearchTerm(searchTerm);
      
      // Trigger custom event for other components
      this.dispatchSearchAnalyzed(searchTerm);
    }
  }

  /**
   * Update icon based on search term analysis with smooth transitions
   * @param {string} searchTerm - The search term to analyze
   */
  updateIconForTerm(searchTerm) {
    if (!this.hasIconTarget) return;
    
    const iconClass = getIcon(searchTerm);
    const iconElement = this.iconTarget.querySelector('i') || this.createIconElement();
    const currentClass = iconElement.className;
    
    // Only update if the icon has actually changed
    if (currentClass !== iconClass) {
      // Add transition classes
      this.iconTarget.classList.add('icon-changing');
      
      // Smooth transition with animation
      setTimeout(() => {
        iconElement.className = iconClass;
        iconElement.setAttribute('aria-hidden', 'true');
        iconElement.setAttribute('title', `Icon for: ${searchTerm || 'search'}`);
        
        // Remove transition class after animation
        setTimeout(() => {
          this.iconTarget.classList.remove('icon-changing');
        }, 300);
      }, 50);
    }
    
    if (!this.iconTarget.querySelector('i')) {
      this.iconTarget.prepend(iconElement);
    }
  }

  /**
   * Update submit button icon contextually based on search term
   * @param {string} searchTerm - The search term to analyze
   */
  updateSubmitIcon(searchTerm) {
    if (!this.hasSubmitIconTarget) return;
    
    const category = this.detectCategory(searchTerm);
    let submitIconText = 'search'; // default
    let ariaLabel = 'search';
    
    // Make submit button icon contextual to search category
    switch (category) {
      case 'coffee':
        submitIconText = 'local_cafe';
        ariaLabel = 'search coffee';
        break;
      case 'food':
        submitIconText = 'restaurant';
        ariaLabel = 'search food';
        break;
      case 'restaurant':
        submitIconText = 'wine_bar';
        ariaLabel = 'search restaurants';
        break;
      default:
        submitIconText = 'search';
        ariaLabel = 'search';
    }
    
    // Only update if different
    if (this.submitIconTarget.textContent !== submitIconText) {
      // Add transition effect
      this.submitIconTarget.style.transform = 'scale(0.8)';
      this.submitIconTarget.style.opacity = '0.7';
      
      setTimeout(() => {
        this.submitIconTarget.textContent = submitIconText;
        this.submitIconTarget.setAttribute('aria-label', ariaLabel);
        
        // Restore normal appearance
        this.submitIconTarget.style.transform = 'scale(1)';
        this.submitIconTarget.style.opacity = '1';
      }, 150);
    }
  }

  /**
   * Create a new icon element
   * @returns {HTMLElement} - New icon element
   */
  createIconElement() {
    const iconElement = document.createElement('i');
    iconElement.setAttribute('aria-hidden', 'true');
    return iconElement;
  }

  /**
   * Apply theme based on search term category
   * @param {string} searchTerm - The search term
   */
  applyTheme(searchTerm) {
    if (!this.hasThemeTarget) return;
    
    const category = this.detectCategory(searchTerm);
    
    // Remove existing theme classes
    this.themeTarget.classList.remove(
      'theme-coffee', 'theme-food', 'theme-restaurant', 'theme-default'
    );
    
    // Add new theme class
    this.themeTarget.classList.add(`theme-${category}`);
  }

  /**
   * Detect the category of the search term
   * @param {string} searchTerm - The search term
   * @returns {string} - The detected category
   */
  detectCategory(searchTerm) {
    if (!searchTerm) return 'default';
    
    const iconClass = getIcon(searchTerm);
    
    // Map icon classes to categories
    if (iconClass.includes('fa-coffee')) return 'coffee';
    if (iconClass.includes('fa-utensils') || iconClass.includes('fa-pizza') || 
        iconClass.includes('fa-hamburger') || iconClass.includes('fa-birthday-cake')) {
      return 'food';
    }
    if (iconClass.includes('fa-wine-glass') || iconClass.includes('fa-beer') || 
        iconClass.includes('fa-store')) {
      return 'restaurant';
    }
    
    return 'default';
  }

  /**
   * Store search term for consistent theming across pages
   * @param {string} searchTerm - The search term to store
   */
  storeSearchTerm(searchTerm) {
    const searchData = {
      term: searchTerm,
      category: this.detectCategory(searchTerm),
      icon: getIcon(searchTerm),
      timestamp: Date.now()
    };
    
    localStorage.setItem('lastSearchData', JSON.stringify(searchData));
    
    // Also store in session for current session persistence
    sessionStorage.setItem('currentSearchTerm', searchTerm);
  }

  /**
   * Load stored theme for consistency across pages
   */
  loadStoredTheme() {
    try {
      const storedData = localStorage.getItem('lastSearchData');
      if (storedData) {
        const searchData = JSON.parse(storedData);
        
        // Only apply if data is recent (within 24 hours)
        const twentyFourHours = 24 * 60 * 60 * 1000;
        if (Date.now() - searchData.timestamp < twentyFourHours) {
          this.applyStoredTheme(searchData);
        }
      }
    } catch (error) {
      console.warn('Failed to load stored search theme:', error);
    }
  }

  /**
   * Apply stored theme data
   * @param {Object} searchData - Stored search data
   */
  applyStoredTheme(searchData) {
    if (this.hasThemeTarget) {
      this.themeTarget.classList.add(`theme-${searchData.category}`);
    }
    
    // Apply stored submit button icon if available
    if (searchData.term) {
      this.updateSubmitIcon(searchData.term);
    }
    
    // Don't automatically fill the input, just apply theme
    // Users might not want their previous search auto-filled
  }

  /**
   * Dispatch custom event when search term is analyzed
   * @param {string} searchTerm - The analyzed search term
   */
  dispatchSearchAnalyzed(searchTerm) {
    const event = new CustomEvent('search:analyzed', {
      detail: {
        term: searchTerm,
        category: this.detectCategory(searchTerm),
        icon: getIcon(searchTerm)
      },
      bubbles: true
    });
    
    this.element.dispatchEvent(event);
  }

  /**
   * Manual method to trigger analysis (can be called from other controllers)
   */
  triggerAnalysis() {
    this.analyzeSearchTerm();
  }

  /**
   * Get current search analysis data
   * @returns {Object} - Current search data
   */
  getCurrentSearchData() {
    return {
      term: this.lastSearchTerm,
      category: this.detectCategory(this.lastSearchTerm),
      icon: getIcon(this.lastSearchTerm)
    };
  }

  /**
   * Clear stored search data
   */
  clearStoredData() {
    localStorage.removeItem('lastSearchData');
    sessionStorage.removeItem('currentSearchTerm');
  }
}
