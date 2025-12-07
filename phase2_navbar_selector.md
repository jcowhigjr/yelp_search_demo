## Phase 2: Add language selector to navbar

### Problem

Language selection needs to be moved from footer to navbar for better UX. Users should easily see and change language from the main navigation area.

### Acceptance Criteria

1. **Add language selector to desktop navbar**
   - Add language selector in top-right area of navbar (before logout)
   - Show current locale as button (e.g., "EN", "FR", "ES", "PT")
   - Clicking opens dropdown with all available locales
   - Use translated language names in dropdown (English, Français, etc.)

2. **Implement dropdown functionality**
   - Dropdown appears below language button
   - Click outside closes dropdown
   - Selecting language navigates to correct locale route
   - Updates I18n.locale and html[lang] attribute

3. **Maintain navbar styling**
   - Language selector matches existing navbar style
   - Uses existing CSS classes and design tokens
   - Responsive on different screen sizes
   - Doesn't break existing navbar layout

### Technical Implementation

#### New Navbar Structure
```erb
<!-- In app/views/layouts/_navbar.html.erb -->
<ul id="nav-mobile" class="right hide-on-med-and-down">
  <!-- existing nav items -->
  
  <!-- Language Selector -->
  <li class="language-selector">
    <button class="language-toggle" aria-haspopup="true" aria-expanded="false">
      <%= current_locale_upcase %>
    </button>
    <div class="language-dropdown" hidden>
      <% I18n.available_locales.each do |locale| %>
        <%= link_to request.params.merge(locale: resolve_locale(locale)),
                    class: ("active" if locale == I18n.locale),
                    "data-locale": locale do %>
          <%= t('.language_name_of_locale', locale:) %>
        <% end %>
      <% end %>
    </div>
  </li>
  
  <!-- existing logout item -->
</ul>
```

#### Basic JavaScript (if needed)
```javascript
// Simple dropdown toggle without complex dependencies
document.querySelector('.language-toggle')?.addEventListener('click', function(e) {
  e.preventDefault();
  const dropdown = this.nextElementSibling;
  const expanded = this.getAttribute('aria-expanded') === 'true';
  
  this.setAttribute('aria-expanded', !expanded);
  dropdown.hidden = expanded;
});

// Close on outside click
document.addEventListener('click', function(e) {
  if (!e.target.closest('.language-selector')) {
    document.querySelector('.language-dropdown')?.setAttribute('hidden', '');
    document.querySelector('.language-toggle')?.setAttribute('aria-expanded', 'false');
  }
});
```

### Files to Modify

- `app/views/layouts/_navbar.html.erb` - Add language selector
- `app/assets/stylesheets/navigation.css` - Add dropdown styles
- `app/helpers/application_helper.rb` - Add `current_locale_upcase` helper

### Definition of Done

- [ ] Language selector visible in navbar
- [ ] Dropdown shows all available languages
- [ ] Language switching works correctly
- [ ] Current locale is highlighted
- [ ] Navbar layout remains intact
- [ ] No JavaScript errors

### Risk Level: MEDIUM
- Involves navbar layout changes
- Requires JavaScript for dropdown
- Needs careful styling to match existing design

### Estimated Effort: 3-4 hours
- HTML structure: 1 hour
- CSS styling: 1-2 hours
- JavaScript functionality: 1 hour
- Testing and refinement: 1 hour

### Dependencies

- **Requires**: Phase 1 (#1173) - Footer cleanup completed
- **Prerequisite for**: Phase 3 (#1175) - Accessibility & mobile

### GitHub Relationships

**Blocked by:** #1173
**Blocks:** #1175

### Deployment Order

**Must be deployed after Phase 1** - This phase adds the language selector to the navbar and assumes the footer has been cleaned up.
- Existing navbar structure must be understood

### Success Metrics

- Users can easily see current language
- Language switching is intuitive and fast
- No impact on existing navbar functionality
- Clean, professional appearance
