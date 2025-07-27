# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Load fixture data for development
if Rails.env.development?
  puts "🌱 Seeding development database..."
  
  # Clear existing data
  puts "  Clearing existing data..."
  Coffeeshop.destroy_all
  UserFavorite.destroy_all
  Review.destroy_all
  Search.destroy_all
  User.destroy_all
  
  # Load fixtures
  puts "  Loading fixture data..."
  
  # Load users from fixtures
  users_data = YAML.load_file(Rails.root.join('test', 'fixtures', 'users.yml'))
  users_data.each do |key, attributes|
    User.create!(attributes)
    puts "    Created user: #{attributes['email']}"
  end
  
  # Load searches from fixtures with proper user associations
  searches_data = YAML.load_file(Rails.root.join('test', 'fixtures', 'searches.yml'))
  searches_data.each do |key, attributes|
    # Handle ERB timestamps in fixture data
    processed_attributes = attributes.dup
    if processed_attributes['created_at']&.include?('Time.current')
      processed_attributes['created_at'] = eval(processed_attributes['created_at'])
    end
    if processed_attributes['updated_at']&.include?('Time.current') 
      processed_attributes['updated_at'] = eval(processed_attributes['updated_at'])
    end
    
    # Find user by email if user_email is specified, otherwise use user_id
    if processed_attributes['user_email']
      user = User.find_by!(email: processed_attributes['user_email'])
      processed_attributes['user_id'] = user.id
      processed_attributes.delete('user_email')
    end
    
    search = Search.create!(processed_attributes)
    puts "    Created search: #{search.query} by #{search.user.email}"
  end
  
  # Create Coffeeshops from Yelp API
  puts "\nCreating coffeeshops from Yelp API..."
  Search.all.each do |search|
    Coffeeshop.get_search_results(search)
  end
  print " ✓ (#{Coffeeshop.count} coffeeshops)"
  
  # Load reviews from fixtures
  if File.exist?(Rails.root.join('test', 'fixtures', 'reviews.yml'))
    reviews_data = YAML.load_file(Rails.root.join('test', 'fixtures', 'reviews.yml'))
    reviews_data.each do |key, attributes|
      # Handle user associations
      if attributes['user_email']
        user = User.find_by!(email: attributes['user_email'])
        attributes['user_id'] = user.id
        attributes.delete('user_email')
      end
      
      # Handle coffeeshop associations
      if attributes['coffeeshop_name']
        coffeeshop = Coffeeshop.find_by!(name: attributes['coffeeshop_name'])
        attributes['coffeeshop_id'] = coffeeshop.id
        attributes.delete('coffeeshop_name')
      end
      
      Review.create!(attributes)
      puts "    Created review for #{Coffeeshop.find(attributes['coffeeshop_id']).name}"
    end
  end
  
  # Load favorites from fixtures
  if File.exist?(Rails.root.join('test', 'fixtures', 'user_favorites.yml'))
    favorites_data = YAML.load_file(Rails.root.join('test', 'fixtures', 'user_favorites.yml'))
    favorites_data.each do |key, attributes|
      # Handle user associations
      if attributes['user_email']
        user = User.find_by!(email: attributes['user_email'])
        attributes['user_id'] = user.id
        attributes.delete('user_email')
      end
      
      # Handle coffeeshop associations  
      if attributes['coffeeshop_name']
        coffeeshop = Coffeeshop.find_by!(name: attributes['coffeeshop_name'])
        attributes['coffeeshop_id'] = coffeeshop.id
        attributes.delete('coffeeshop_name')
      end
      
      UserFavorite.create!(attributes)
      puts "    Created favorite: #{User.find(attributes['user_id']).email} ❤️ #{Coffeeshop.find(attributes['coffeeshop_id']).name}"
    end
  end
  
  puts "✅ Seeding completed!"
  puts "   #{User.count} users"
  puts "   #{Search.count} searches"  
  puts "   #{Coffeeshop.count} coffeeshops"
  puts "   #{Review.count} reviews"
  puts "   #{UserFavorite.count} favorites"
  
else
  puts "⚠️  Seeding is only available in development environment"
end
