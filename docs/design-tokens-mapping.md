# Design Tokens Mapping: Prototype to Rails UI

This document audits the design tokens from the Website Design Improvement prototype and maps them to the Rails application structure.

## Overview

The Website Design Improvement prototype uses Tailwind CSS v4 with custom CSS variables for theming. The Rails app already has partial implementation of these tokens and uses the same Tailwind CSS v4 framework.

## Token Categories

### 1. Color Tokens

#### Prototype Colors (from `globals.css`)
```css
:root {
  --color-primary: #4B9CD3;        /* Light blue */
  --color-primary-dark: #3A8CC7;   /* Darker blue */
  --color-button-blue: #1C5B82;   /* Deep blue for buttons */
  --color-bg: #FFFFFF;            /* Background */
  --color-text: #000000;           /* Text */
  --color-yelp: #FF1A1A;           /* Yelp brand red */
  --color-border: #e5e5e5;         /* Light gray borders */
}

[data-theme="dark"] {
  --color-bg: #18181B;             /* Dark background */
  --color-text: #FFFFFF;           /* Light text */
  --color-border: #3f3f46;         /* Dark borders */
}
```

#### Current Rails Implementation
The Rails `application.css` already references these same variables:
- Uses `var(--color-bg)`, `var(--color-text)`, `var(--color-border)` throughout
- Has Yelp brand color: `.yelp_color { color: #ff1a1a !important; }`
- Button colors: `.btn-large`, `.btn-small` use `#1c5b82` (matches `--color-button-blue`)

#### Gaps/Conflicts
- **Missing**: `--color-primary` and `--color-primary-dark` are not defined in Rails
- **Conflict**: Rails uses hardcoded colors in some places (e.g., `.btn-large` background)
- **Gap**: No systematic color token definition in Rails CSS

### 2. Typography Tokens

#### Prototype Typography
```css
.page-name {
  font-size: 60px;
  line-height: 1.2;
}

.page-text {
  font-size: 30px;
  line-height: 1.4;
}

.form-link {
  font-size: 20px;
}

h1 {
  font-size: 60px;
  line-height: 1.2;
}

h2 {
  font-size: 48px;
  line-height: 1.3;
}

h3 {
  font-size: 30px;
  line-height: 1.4;
}

p {
  font-size: 16px;
  line-height: 1.6;
}
```

#### Current Rails Implementation
Rails `application.css` has matching classes:
- `.page-name { font-size: 60px; margin-bottom: 40px; }`
- `.page-text { font-size: 30px; padding: 20px; }`
- `.form-link { font-size: 20px; }`

#### Gaps/Conflicts
- **Good alignment**: Typography tokens are already implemented
- **Missing**: Line height definitions are not consistent
- **Gap**: No systematic heading scale (h1, h2, h3) definitions

### 3. Spacing & Layout Tokens

#### Prototype Layout Patterns
- Uses Tailwind's spacing scale (0.25rem base unit)
- Container utilities: `container mx-auto px-4 py-8`
- Max-width containers: `max-w-3xl`, `max-w-6xl`
- Grid layouts: `grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3`
- Gap utilities: `gap-4`, `gap-6`

#### Current Rails Implementation
- Uses Materialize CSS grid system primarily
- Some custom spacing: `.page-container { margin-top: 20px; padding: 30px 50px; }`
- No systematic spacing scale

#### Gaps/Conflicts
- **Major gap**: Rails uses Materialize, prototype uses Tailwind utilities
- **Conflict**: Different spacing paradigms
- **Missing**: Responsive grid system

### 4. Component-Specific Tokens

#### Navigation
```css
.language-nav__link {
  color: var(--color-text);
  text-decoration: none;
  transition: all 0.2s;
  font-size: 16px;
}

.language-nav__link--active {
  font-weight: 600;
  text-decoration: underline;
}
```

Rails already has matching `.language-nav__link` styles.

#### Buttons
- Prototype uses `--color-button-blue: #1C5B82`
- Rails buttons use same color: `.btn-large { background-color: #1c5b82; }`

#### Cards
- Prototype uses shadow utilities: `shadow-lg`, `shadow-sm`
- Rails uses Materialize cards with custom dark mode overrides

## Proposed Rails Implementation

### 1. Centralize Color Tokens

**File**: `app/assets/stylesheets/design-tokens.css`

```css
@layer base {
  :root {
    --color-primary: #4B9CD3;
    --color-primary-dark: #3A8CC7;
    --color-button-blue: #1C5B82;
    --color-bg: #FFFFFF;
    --color-text: #000000;
    --color-yelp: #FF1A1A;
    --color-border: #e5e5e5;
  }

  [data-theme="dark"] {
    --color-bg: #18181B;
    --color-text: #FFFFFF;
    --color-border: #3f3f46;
  }
}
```

### 2. Typography System

**File**: `app/assets/stylesheets/typography.css`

```css
@layer base {
  .page-name {
    font-size: 60px;
    line-height: 1.2;
  }

  .page-text {
    font-size: 30px;
    line-height: 1.4;
  }

  .form-link {
    font-size: 20px;
  }

  h1 {
    font-size: 60px;
    line-height: 1.2;
  }

  h2 {
    font-size: 48px;
    line-height: 1.3;
  }

  h3 {
    font-size: 30px;
    line-height: 1.4;
  }

  p {
    font-size: 16px;
    line-height: 1.6;
  }
}
```

### 3. Tailwind Configuration

**File**: `config/tailwind.config.js` (restore from .bak and extend)

```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/components/**/*.{erb,haml,html,slim,rb}',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        primary: 'var(--color-primary)',
        'primary-dark': 'var(--color-primary-dark)',
        'button-blue': 'var(--color-button-blue)',
        bg: 'var(--color-bg)',
        text: 'var(--color-text)',
        yelp: 'var(--color-yelp)',
        border: 'var(--color-border)',
      },
      fontFamily: {
        sans: ['Nunito', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
```

### 4. Component Structure

**Recommendation**: Create reusable partials:
- `_coffeeshop_card.html.erb` (matching prototype card layout)
- `_search_bar.html.erb` (matching prototype search bar)
- `_navigation.html.erb` (using existing nav styles)

## Dark Mode Implementation

### Current State
- Theme controller exists: `app/javascript/controllers/theme_controller.js`
- Uses `data-theme` attribute on `<html>` element
- Some dark mode styles already in `application.css`

### Recommended Enhancement
1. Complete CSS variable definitions for dark mode
2. Add smooth transitions: `transition: background-color 0.3s, color 0.3s`
3. Ensure all components respect theme variables

## Migration Strategy

### Phase 0 (Current Issue)
- ✅ Document token mapping
- ✅ Identify gaps and conflicts
- ✅ Propose implementation approach

### Phase 1-5 (Subsequent Issues)
- Gradually replace Materialize patterns with Tailwind utilities
- Implement systematic token usage
- Maintain backward compatibility during transition

## Testing Considerations

### Visual Regression Testing
- Ensure token changes don't break existing UI
- Test both light and dark themes
- Verify responsive behavior

### System Tests
- Current tests should continue passing
- New tests for token-based components
- Cross-browser consistency checks

## Conclusion

The prototype and Rails app share a good foundation:
- Both use Tailwind CSS v4
- Typography tokens are already aligned
- Theme infrastructure exists

**Key gaps to address**:
1. Systematic color token definition
2. Complete typography scale
3. Spacing system migration from Materialize to Tailwind
4. Component standardization

**Implementation priority**:
1. Define missing color tokens
2. Standardize typography
3. Create reusable component partials
4. Migrate spacing/layout patterns
5. Enhance dark mode support
