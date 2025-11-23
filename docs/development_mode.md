# Development Mode - Local Data

## Overview

The application includes a development-only flag that allows bypassing Yelp API calls and using local/mock data instead. This is useful for:

- Development without requiring Yelp API credentials
- Testing without external API dependencies  
- Avoiding API rate limits during development
- Working offline

## Configuration

### Environment Variable

Set the `USE_LOCAL_DATA` environment variable to `true` to enable local data mode:

```bash
export USE_LOCAL_DATA=true
```

Or prefix your Rails commands:

```bash
USE_LOCAL_DATA=true rails server
USE_LOCAL_DATA=true rails console
```

### How It Works

When `USE_LOCAL_DATA=true` is set:

1. The `Coffeeshop.get_search_results` method checks for the `Rails.application.config.use_local_data` flag
2. If enabled, it skips the RestClient API call to Yelp
3. Instead, it returns existing coffeeshops associated with the search, or creates mock data

### Mock Data Generation

If no existing coffeeshops are found for a search, the system generates mock businesses based on the search query:

- **coffee** searches → "Local Coffee House" + "Premium Coffee"
- **yoga** searches → "Zen Yoga Studio" + "Premium Yoga"  
- **pizza** searches → "Tony's Pizza Place" + "Premium Pizza"
- **taco** searches → "El Taco Loco" + "Premium Taco"
- **other** searches → "[Query] Shop" + "Premium [Query]"

Each mock search returns 2 businesses with realistic data:
- Unique addresses per search type (to avoid conflicts)
- Phone numbers: (555) 123-4567 and (555) 987-6543
- Ratings: 4.5 and 4.0 stars respectively
- Yelp URLs and placeholder images

### Benefits

- ✅ Preserves application flow and logic
- ✅ No changes to controllers or views needed
- ✅ Works with existing tests and fixtures
- ✅ Easy to enable/disable with environment variable
- ✅ Provides consistent mock data for development

### Usage Examples

```bash
# Start server with local data
USE_LOCAL_DATA=true rails server

# Run tests with local data  
USE_LOCAL_DATA=true rails test

# Rails console with local data
USE_LOCAL_DATA=true rails console
```

In Rails console:
```ruby
# Check if local data is enabled
Rails.application.config.use_local_data
# => true

# Perform a search - will use mock data
search = Search.create!(query: "coffee", latitude: 40.7128, longitude: -74.0060)
Coffeeshop.get_search_results(search)
# => Creates "Local Coffee House" and "Premium Coffee" entries
```
