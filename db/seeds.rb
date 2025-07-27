# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Load fixture data for development environment

require 'yaml'

# Helper method to get default password for fixtures
def default_password
  'TerriblePassword'
end

print "Loading fixture data for development..."

begin
  # Load fixture files
  users_fixtures = YAML.load_file(Rails.root.join('test/fixtures/users.yml'))
  searches_fixtures = YAML.load_file(Rails.root.join('test/fixtures/searches.yml'))
  coffeeshops_fixtures = YAML.load_file(Rails.root.join('test/fixtures/coffeeshops.yml'))
  reviews_fixtures = YAML.load_file(Rails.root.join('test/fixtures/reviews.yml'))
  user_favorites_fixtures = YAML.load_file(Rails.root.join('test/fixtures/user_favorites.yml'))

  # Clear existing data (optional - uncomment if you want to reset)
  # UserFavorite.destroy_all
  # Review.destroy_all
  # Coffeeshop.destroy_all
  # Search.destroy_all
  # User.destroy_all

  # Create Users from fixtures
  print "\nCreating users..."
  users_fixtures.each do |fixture_name, attributes|
    next if fixture_name.start_with?('#') # Skip comments
    
    User.find_or_create_by(id: attributes['id']) do |user|
      user.name = attributes['name']
      user.email = attributes['email']
      user.password = default_password
      user.password_confirmation = default_password
    end
  end
  print " ✓ (#{User.count} users)"

  # Create Searches from fixtures
  print "\nCreating searches..."
  searches_fixtures.each do |fixture_name, attributes|
    next if fixture_name.start_with?('#') # Skip comments
    next if attributes.nil? # Skip empty entries
    
    Search.find_or_create_by(id: attributes['id']) do |search|
      search.query = attributes['query']
      search.latitude = attributes['latitude']
      search.longitude = attributes['longitude']
      
      # Handle user association
      if attributes['user'].present?
        user_fixture_name = attributes['user']
        user_data = users_fixtures[user_fixture_name]
        search.user_id = user_data['id'] if user_data
      end
      
      # Handle ERB timestamps by evaluating them
      if attributes['created_at'].present?
        if attributes['created_at'].include?('<%=')
          # This is an ERB template, evaluate it
          search.created_at = eval(attributes['created_at'].gsub(/<%=\s*(.*)\s*%>/, '\1'))
        else
          search.created_at = Time.parse(attributes['created_at'])
        end
      end
      
      if attributes['updated_at'].present?
        if attributes['updated_at'].include?('<%=')
          # This is an ERB template, evaluate it
          search.updated_at = eval(attributes['updated_at'].gsub(/<%=\s*(.*)\s*%>/, '\1'))
        else
          search.updated_at = Time.parse(attributes['updated_at'])
        end
      end
    end
  end
  print " ✓ (#{Search.count} searches)"

  # Create Coffeeshops from fixtures
  # print "\nCreating coffeeshops..."
  # coffeeshops_fixtures.each do |fixture_name, attributes|
  #   next if fixture_name.start_with?('#') # Skip comments
  #   
  #   Coffeeshop.find_or_create_by(id: attributes['id']) do |coffeeshop|
  #     coffeeshop.name = attributes['name']
  #     coffeeshop.address = attributes['address']
  #     coffeeshop.rating = attributes['rating']
  #     coffeeshop.yelp_url = attributes['yelp_url']
  #     coffeeshop.image_url = attributes['image_url']
  #     coffeeshop.phone_number = attributes['phone_number']
  #     coffeeshop.search_id = attributes['search_id']
  #   end
  # end
  # print " ✓ (#{Coffeeshop.count} coffeeshops)"

  # Create Coffeeshops from Yelp API
  print "\nCreating coffeeshops from Yelp API..."
  Search.all.each do |search|
    Coffeeshop.get_search_results(search)
  end
  print " ✓ (#{Coffeeshop.count} coffeeshops)"

  # Create Reviews from fixtures
  print "\nCreating reviews..."
  reviews_fixtures.each do |fixture_name, attributes|
    next if fixture_name.start_with?('#') # Skip comments
    
    # Clean up attributes (remove trailing commas from fixture file)
    clean_attributes = {}
    attributes.each do |key, value|
      if value.is_a?(String) && value.end_with?(',')
        clean_attributes[key] = value.chomp(',')
      else
        clean_attributes[key] = value
      end
    end
    
    Review.find_or_create_by(id: clean_attributes['id']) do |review|
      review.content = clean_attributes['content']
      review.rating = clean_attributes['rating'].to_f
      review.user_id = clean_attributes['user_id']
      review.coffeeshop_id = clean_attributes['coffeeshop_id']
    end
  end
  print " ✓ (#{Review.count} reviews)"

  # Create UserFavorites from fixtures
  print "\nCreating user favorites..."
  user_favorites_fixtures.each do |fixture_name, attributes|
    next if fixture_name.start_with?('#') # Skip comments
    
    UserFavorite.find_or_create_by(
      user_id: attributes['user_id'],
      coffeeshop_id: attributes['coffeeshop_id']
    )
  end
  print " ✓ (#{UserFavorite.count} user favorites)"

  puts "\n\n✅ Fixture data loaded successfully!"
  puts "Summary:"
  puts "  - Users: #{User.count}"
  puts "  - Searches: #{Search.count}"
  puts "  - Coffeeshops: #{Coffeeshop.count}"
  puts "  - Reviews: #{Review.count}"
  puts "  - User Favorites: #{UserFavorite.count}"

rescue => e
  puts "\n\n❌ Error loading fixture data: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  raise e
end
