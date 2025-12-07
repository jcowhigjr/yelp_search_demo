## Phase 3: Implement accessibility and mobile optimizations for language selector

### Problem

The language selector needs to be accessible and work well on mobile devices. This includes proper ARIA attributes, keyboard navigation, and mobile-friendly touch targets.

### Acceptance Criteria

1. **Accessibility compliance**
   - Language toggle button has proper ARIA attributes (`aria-haspopup`, `aria-expanded`)
   - Dropdown menu items are focusable and keyboard navigable
   - Screen readers can identify the control and read language options
   - Focus management works correctly (focus stays in dropdown)

2. **Mobile optimization**
   - Language selector tap target is at least 44x44px on mobile
   - Dropdown aligns properly on narrow viewports (no clipping)
   - Adequate spacing from screen edges for easy tapping
   - Touch-friendly interaction patterns

3. **Keyboard navigation**
   - Tab key focuses language toggle button
   - Enter/Space opens dropdown
   - Arrow keys navigate dropdown options
   - Escape closes dropdown
   - Focus returns to toggle button after selection

### Technical Implementation

#### Enhanced HTML Structure
```erb
<li class="language-selector">
  <button class="language-toggle" 
          aria-haspopup="true" 
          aria-expanded="false"
          aria-label="Select language">
    <%= current_locale_upcase %>
  </button>
  <ul class="language-dropdown" 
      role="menu" 
      aria-labelledby="language-toggle"
      hidden>
    <% I18n.available_locales.each do |locale| %>
      <li role="none">
        <%= link_to t('.language_name_of_locale', locale:),
                    request.params.merge(locale: resolve_locale(locale)),
                    role: "menuitem",
                    class: ("active" if locale == I18n.locale),
                    "data-locale": locale do %>
          <%= t('.language_name_of_locale', locale:) %>
        <% end %>
      </li>
    <% end %>
  </ul>
</li>
```

#### Enhanced JavaScript
```javascript
class LanguageSelector {
  constructor(element) {
    this.toggle = element.querySelector('.language-toggle');
    this.dropdown = element.querySelector('.language-dropdown');
    this.init();
  }

  init() {
    // Toggle dropdown
    this.toggle.addEventListener('click', (e) => {
      e.preventDefault();
      this.toggleDropdown();
    });

    // Keyboard navigation
    this.toggle.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        this.toggleDropdown();
      }
    });

    // Dropdown keyboard navigation
    this.dropdown.addEventListener('keydown', (e) => {
      this.handleKeydown(e);
    });

    // Close on outside click
    document.addEventListener('click', (e) => {
      if (!this.element.contains(e.target)) {
        this.close();
      }
    });
  }

  toggleDropdown() {
    const isOpen = this.toggle.getAttribute('aria-expanded') === 'true';
    isOpen ? this.close() : this.open();
  }

  open() {
    this.toggle.setAttribute('aria-expanded', 'true');
    this.dropdown.hidden = false;
    this.dropdown.querySelector('a').focus();
  }

  close() {
    this.toggle.setAttribute('aria-expanded', 'false');
    this.dropdown.hidden = true;
    this.toggle.focus();
  }

  handleKeydown(e) {
    const items = Array.from(this.dropdown.querySelectorAll('a'));
    const currentIndex = items.indexOf(document.activeElement);

    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        items[(currentIndex + 1) % items.length].focus();
        break;
      case 'ArrowUp':
        e.preventDefault();
        items[currentIndex === 0 ? items.length - 1 : currentIndex - 1].focus();
        break;
      case 'Escape':
        e.preventDefault();
        this.close();
        break;
    }
  }
}

// Initialize selector
document.addEventListener('DOMContentLoaded', () => {
  const selector = document.querySelector('.language-selector');
  if (selector) new LanguageSelector(selector);
});
```

#### Mobile-First CSS
```css
.language-selector {
  position: relative;
}

.language-toggle {
  min-height: 44px;
  min-width: 44px;
  padding: 8px 12px;
  /* Ensure touch-friendly size */
}

.language-dropdown {
  position: absolute;
  top: 100%;
  right: 0;
  min-width: 150px;
  max-width: 90vw; /* Prevent viewport overflow on mobile */
  z-index: 1000;
}

/* Mobile adjustments */
@media (max-width: 768px) {
  .language-dropdown {
    right: -10px; /* Add some breathing room */
    max-width: calc(100vw - 20px);
  }
}

/* Focus styles for accessibility */
.language-toggle:focus,
.language-dropdown a:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}
```

### Files to Modify

- `app/views/layouts/_navbar.html.erb` - Update HTML structure
- `app/assets/stylesheets/navigation.css` - Add mobile and accessibility styles
- `app/assets/javascripts/language_selector.js` - New JavaScript file (or add to existing)
- `app/views/layouts/application.html.erb` - Include JavaScript file

### Definition of Done

- [ ] All ARIA attributes are properly implemented
- [ ] Keyboard navigation works completely
- [ ] Mobile tap targets meet 44x44px minimum
- [ ] Dropdown aligns properly on all screen sizes
- [ ] Screen reader testing passes
- [ ] No JavaScript errors

### Risk Level: MEDIUM
- Requires accessibility testing
- Mobile responsive design considerations
- JavaScript complexity for keyboard navigation

### Estimated Effort: 4-5 hours
- Accessibility implementation: 2 hours
- Mobile optimization: 1-2 hours
- Testing and refinement: 1-2 hours

### Dependencies

- **Requires**: Phase 2 (#1174) - Navbar selector completed
- **Prerequisite for**: Phase 4 (#1176) - Testing

### GitHub Relationships

**Blocked by:** #1174
**Blocks:** #1176

### Deployment Order

**Must be deployed after Phase 2** - This phase builds on the basic navbar selector to add accessibility and mobile optimizations.
- Need access to screen reader for testing
- Mobile device testing recommended

### Success Metrics

- WCAG 2.1 AA compliance for language selector
- Smooth mobile experience
- Keyboard-only users can operate selector
- Screen reader users understand and can use selector
