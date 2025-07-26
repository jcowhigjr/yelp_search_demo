# app/helpers/favorites_helper.rb
module FavoritesHelper
  # Icon mappings for different search terms
  ICON_BY_TERM = {
    /coffee|cafe|espresso|latte|cappuccino|starbucks|dunkin/i => "☕️",
    /taco|tacos|mexican|burrito|quesadilla/i => "🌮",
    /pizza|pizzeria|italian|pepperoni/i => "🍕",
    /burger|hamburger|cheeseburger|fast.food/i => "🍔",
    /sushi|japanese|sashimi|ramen/i => "🍣",
    /chinese|dim.sum|noodles/i => "🥢",
    /ice.cream|dessert|cake|bakery/i => "🍰",
    /bar|beer|brewery|pub/i => "🍺",
    /wine|vineyard|winery/i => "🍷",
    /restaurant|dining|food/i => "🍽️"
  }.freeze

  # Get contextual favorite icon based on search term
  # @param term [String] The search term to analyze
  # @return [String] The appropriate emoji icon or default heart
  def favorite_icon_for(term)
    return "❤️" if term.blank?
    
    ICON_BY_TERM.find { |regex, _| term =~ regex }&.last || "❤️"
  end

  # Get both filled and unfilled versions of the contextual icon
  # @param term [String] The search term to analyze
  # @param is_favorited [Boolean] Whether the item is currently favorited
  # @return [Hash] Hash with :filled and :unfilled icon versions
  def favorite_icon_states_for(term, is_favorited = false)
    base_icon = favorite_icon_for(term)
    
    # For most food emojis, we'll use a grayscale/outline version for unfavorited
    unfilled_variants = {
      "☕️" => "☕",  # Coffee cup (less vibrant)
      "🌮" => "🥙",  # Taco -> Stuffed flatbread (similar shape, less specific)
      "🍕" => "🍽️", # Pizza -> Plate (food context but generic)
      "🍔" => "🍽️", # Burger -> Plate
      "🍣" => "🍽️", # Sushi -> Plate
      "🥢" => "🍽️", # Chopsticks -> Plate
      "🍰" => "🍽️", # Cake -> Plate
      "🍺" => "🥤",  # Beer -> Cup with straw (drink context)
      "🍷" => "🥤",  # Wine -> Cup with straw
      "🍽️" => "🍽️", # Plate stays the same
      "❤️" => "🤍"   # Red heart -> White heart
    }
    
    {
      filled: base_icon,
      unfilled: unfilled_variants[base_icon] || "🤍",
      current: is_favorited ? base_icon : (unfilled_variants[base_icon] || "🤍")
    }
  end

  # Generate CSS classes for favorite button styling based on search term
  # @param term [String] The search term to analyze
  # @return [String] CSS classes for styling
  def favorite_button_classes_for(term)
    base_classes = "favorite-btn"
    
    case favorite_icon_for(term)
    when "☕️"
      "#{base_classes} favorite-coffee"
    when "🌮"
      "#{base_classes} favorite-taco"
    when "🍕"
      "#{base_classes} favorite-pizza"
    when "🍔"
      "#{base_classes} favorite-burger"
    when "🍣"
      "#{base_classes} favorite-sushi"
    when "🥢"
      "#{base_classes} favorite-chinese"
    when "🍰"
      "#{base_classes} favorite-dessert"
    when "🍺"
      "#{base_classes} favorite-beer"
    when "🍷"
      "#{base_classes} favorite-wine"
    when "🍽️"
      "#{base_classes} favorite-restaurant"
    else
      "#{base_classes} favorite-default"
    end
  end
end
