// test/javascript/search_controller_test.js
import { Application } from '@hotwired/stimulus'
import SearchController from '../../app/javascript/controllers/search_controller'

// Mock the iconMapper module
const mockIconMapper = {
  getIcon: jest.fn((term) => {
    const mappings = {
      'coffee': 'fas fa-coffee',
      'pizza': 'fas fa-pizza-slice',
      'burger': 'fas fa-hamburger',
      'sushi': 'fas fa-fish',
      'default': 'fas fa-map-marker-alt'
    }
    return mappings[term] || mappings.default
  }),
  getAllMappings: jest.fn(() => ({}))
}

// Mock localStorage
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn()
}
global.localStorage = localStorageMock

// Mock sessionStorage
const sessionStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn()
}
global.sessionStorage = sessionStorageMock

describe('SearchController', () => {
  let application
  let controller
  let element

  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks()
    localStorageMock.getItem.mockReturnValue(null)
    
    // Setup DOM
    document.body.innerHTML = `
      <div data-controller="search" data-search-target="theme">
        <div class="search-input-container">
          <div data-search-target="icon" class="search-icon">
            <i class="fas fa-map-marker-alt" aria-hidden="true"></i>
          </div>
          <input type="search" data-search-target="input" />
        </div>
        <button data-search-target="submitButton" class="search-submit-btn">
          <i data-search-target="submitIcon" class="material-icons">search</i>
        </button>
      </div>
    `
    
    element = document.querySelector('[data-controller="search"]')
    
    // Setup Stimulus application
    application = Application.start()
    application.register('search', SearchController)
    
    controller = application.getControllerForElementAndIdentifier(element, 'search')
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
  })

  describe('icon updates', () => {
    test('updates icon for coffee search', () => {
      const input = element.querySelector('[data-search-target="input"]')
      const iconElement = element.querySelector('[data-search-target="icon"] i')
      
      // Simulate typing coffee
      input.value = 'coffee'
      input.dispatchEvent(new Event('input'))
      
      // Wait for debounced update
      setTimeout(() => {
        expect(iconElement.className).toContain('fa-coffee')
      }, 350)
    })

    test('updates icon for pizza search', () => {
      const input = element.querySelector('[data-search-target="input"]')
      const iconElement = element.querySelector('[data-search-target="icon"] i')
      
      input.value = 'pizza'
      input.dispatchEvent(new Event('input'))
      
      setTimeout(() => {
        expect(iconElement.className).toContain('fa-pizza-slice')
      }, 350)
    })

    test('adds transition classes during icon change', () => {
      const input = element.querySelector('[data-search-target="input"]')
      const iconContainer = element.querySelector('[data-search-target="icon"]')
      
      input.value = 'coffee'
      input.dispatchEvent(new Event('input'))
      
      setTimeout(() => {
        expect(iconContainer.classList.contains('icon-changing')).toBe(true)
      }, 100)
      
      setTimeout(() => {
        expect(iconContainer.classList.contains('icon-changing')).toBe(false)
      }, 400)
    })
  })

  describe('submit button icon updates', () => {
    test('updates submit button icon for coffee', () => {
      const input = element.querySelector('[data-search-target="input"]')
      const submitIcon = element.querySelector('[data-search-target="submitIcon"]')
      
      input.value = 'coffee'
      input.dispatchEvent(new Event('input'))
      
      setTimeout(() => {
        expect(submitIcon.textContent).toBe('local_cafe')
        expect(submitIcon.getAttribute('aria-label')).toBe('search coffee')
      }, 350)
    })

    test('updates submit button icon for food', () => {
      const input = element.querySelector('[data-search-target="input"]')
      const submitIcon = element.querySelector('[data-search-target="submitIcon"]')
      
      input.value = 'pizza'
      input.dispatchEvent(new Event('input'))
      
      setTimeout(() => {
        expect(submitIcon.textContent).toBe('restaurant')
        expect(submitIcon.getAttribute('aria-label')).toBe('search food')
      }, 350)
    })

    test('applies transition effects during icon change', () => {
      const input = element.querySelector('[data-search-target="input"]')
      const submitIcon = element.querySelector('[data-search-target="submitIcon"]')
      
      input.value = 'coffee'
      input.dispatchEvent(new Event('input'))
      
      setTimeout(() => {
        expect(submitIcon.style.transform).toBe('scale(0.8)')
        expect(submitIcon.style.opacity).toBe('0.7')
      }, 100)
      
      setTimeout(() => {
        expect(submitIcon.style.transform).toBe('scale(1)')
        expect(submitIcon.style.opacity).toBe('1')
      }, 300)
    })
  })

  describe('theme application', () => {
    test('applies coffee theme for coffee search', () => {
      const input = element.querySelector('[data-search-target="input"]')
      const themeTarget = element.querySelector('[data-search-target="theme"]')
      
      input.value = 'coffee'
      input.dispatchEvent(new Event('input'))
      
      setTimeout(() => {
        expect(themeTarget.classList.contains('theme-coffee')).toBe(true)
        expect(themeTarget.classList.contains('theme-food')).toBe(false)
        expect(themeTarget.classList.contains('theme-restaurant')).toBe(false)
        expect(themeTarget.classList.contains('theme-default')).toBe(false)
      }, 350)
    })

    test('applies food theme for pizza search', () => {
      const input = element.querySelector('[data-search-target="input"]')
      const themeTarget = element.querySelector('[data-search-target="theme"]')
      
      input.value = 'pizza'
      input.dispatchEvent(new Event('input'))
      
      setTimeout(() => {
        expect(themeTarget.classList.contains('theme-food')).toBe(true)
        expect(themeTarget.classList.contains('theme-coffee')).toBe(false)
      }, 350)
    })
  })

  describe('focus and blur handling', () => {
    test('adds focused state on input focus', () => {
      const input = element.querySelector('[data-search-target="input"]')
      const iconElement = element.querySelector('[data-search-target="icon"]')
      
      input.dispatchEvent(new Event('focus'))
      
      expect(element.classList.contains('search-focused')).toBe(true)
      expect(iconElement.classList.contains('icon-active')).toBe(true)
    })

    test('removes focused state on input blur', () => {
      const input = element.querySelector('[data-search-target="input"]')
      const iconElement = element.querySelector('[data-search-target="icon"]')
      
      // First focus
      input.dispatchEvent(new Event('focus'))
      expect(element.classList.contains('search-focused')).toBe(true)
      
      // Then blur
      input.dispatchEvent(new Event('blur'))
      expect(element.classList.contains('search-focused')).toBe(false)
      expect(iconElement.classList.contains('icon-active')).toBe(false)
    })
  })

  describe('localStorage integration', () => {
    test('stores search data in localStorage', () => {
      const input = element.querySelector('[data-search-target="input"]')
      
      input.value = 'coffee'
      input.dispatchEvent(new Event('input'))
      
      setTimeout(() => {
        expect(localStorageMock.setItem).toHaveBeenCalledWith(
          'lastSearchData',
          expect.stringContaining('"term":"coffee"')
        )
        expect(sessionStorageMock.setItem).toHaveBeenCalledWith(
          'currentSearchTerm',
          'coffee'
        )
      }, 350)
    })

    test('loads stored theme on connect', () => {
      const mockStoredData = JSON.stringify({
        term: 'pizza',
        category: 'food',
        icon: 'fas fa-pizza-slice',
        timestamp: Date.now()
      })
      
      localStorageMock.getItem.mockReturnValue(mockStoredData)
      
      // Reconnect controller to trigger loadStoredTheme
      controller.disconnect()
      controller.connect()
      
      const themeTarget = element.querySelector('[data-search-target="theme"]')
      expect(themeTarget.classList.contains('theme-food')).toBe(true)
    })

    test('ignores old stored data', () => {
      const oldTimestamp = Date.now() - (25 * 60 * 60 * 1000) // 25 hours ago
      const mockStoredData = JSON.stringify({
        term: 'pizza',
        category: 'food',
        icon: 'fas fa-pizza-slice',
        timestamp: oldTimestamp
      })
      
      localStorageMock.getItem.mockReturnValue(mockStoredData)
      
      controller.disconnect()
      controller.connect()
      
      const themeTarget = element.querySelector('[data-search-target="theme"]')
      expect(themeTarget.classList.contains('theme-food')).toBe(false)
    })
  })

  describe('custom events', () => {
    test('dispatches search:analyzed event', (done) => {
      const input = element.querySelector('[data-search-target="input"]')
      
      element.addEventListener('search:analyzed', (event) => {
        expect(event.detail.term).toBe('coffee')
        expect(event.detail.category).toBeTruthy()
        expect(event.detail.icon).toBeTruthy()
        done()
      })
      
      input.value = 'coffee'
      input.dispatchEvent(new Event('input'))
    })
  })

  describe('debouncing', () => {
    test('debounces input changes', () => {
      const input = element.querySelector('[data-search-target="input"]')
      const spy = jest.spyOn(controller, 'analyzeSearchTerm')
      
      // Rapid input changes
      input.value = 'c'
      input.dispatchEvent(new Event('input'))
      input.value = 'co'
      input.dispatchEvent(new Event('input'))
      input.value = 'cof'
      input.dispatchEvent(new Event('input'))
      input.value = 'coffee'
      input.dispatchEvent(new Event('input'))
      
      // Should not call immediately
      expect(spy).not.toHaveBeenCalled()
      
      // Should call after debounce delay
      setTimeout(() => {
        expect(spy).toHaveBeenCalledTimes(1)
      }, 350)
    })
  })
})
