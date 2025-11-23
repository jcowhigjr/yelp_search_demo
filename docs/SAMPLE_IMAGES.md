# Sample Images Implementation

## Overview

This application now includes lightweight SVG sample images for seed data to provide a self-contained development experience without relying on external image services like Unsplash.

## Sample Images Created

### Fixture Images
- `sample_coffeeshop_1.svg` - Traditional coffee house with warm brown tones
- `sample_coffeeshop_2.svg` - Modern coffee shop (Bellwood Coffee) with green theme
- `sample_coffee_generic.svg` - Generic coffee shop with blue theme
- `sample_taco_shop.svg` - Colorful taco shop with Mexican-inspired design

### Image Features
- **Lightweight**: All images are vector-based SVGs (~2-4KB each)
- **Self-contained**: No external dependencies or API calls
- **Themed**: Each image matches the business type it represents
- **Scalable**: SVG format ensures crisp rendering at any size

## Integration Points

### Fixture Files
The `test/fixtures/coffeeshops.yml` file now includes sample image URLs:
```yaml
one:
  name: Local Coffee House
  image_url: /assets/sample_coffeeshop_1.svg
  # ... other fields

two:
  name: Bellwood Coffee  
  image_url: /assets/sample_coffeeshop_2.svg
  # ... other fields
```

### Mock Data Generation
The `Coffeeshop` model's `generate_mock_business_data` method now assigns appropriate images based on search terms:
- Coffee searches → Coffee shop images
- Taco searches → Taco shop image
- Other searches → Generic shop image

### Fallback Strategy
The views still maintain Unsplash fallback for cases where `image_url` is empty:
```erb
<%= image_tag(coffeeshop.large_image_url.presence ||
    "https://source.unsplash.com/featured/400x400/?#{@coffeeshop.search&.query || 'coffee'}",
    class: 'card-img responsive-img') %>
```

## Benefits

1. **Offline Development**: No internet required for sample images
2. **Consistent Testing**: Predictable images for automated tests
3. **Fast Loading**: Small SVG files load instantly
4. **No API Limits**: No concerns about Unsplash rate limiting
5. **Customizable**: Easy to modify or add new themed images

## Adding New Sample Images

To add images for new business types:

1. Create a new SVG file in `app/assets/images/`
2. Update the `generate_mock_business_data` method in `app/models/coffeeshop.rb`
3. Add the new image path to the appropriate case statement

Example:
```ruby
when /pizza/
  { name: 'Tony\'s Pizza Place', category: 'Pizza', street_num: '300', image: '/assets/sample_pizza_shop.svg' }
```
