require 'test_helper'

class FavoritesHelperTest < ActionView::TestCase
  include FavoritesHelper

  test "favorite_icon_for returns coffee emoji for coffee-related terms" do
    coffee_terms = [
      "coffee", "Coffee", "COFFEE",
      "cafe", "Cafe", "coffee shop",
      "espresso", "latte", "cappuccino",
      "starbucks", "dunkin"
    ]
    
    coffee_terms.each do |term|
      assert_equal "☕️", favorite_icon_for(term), 
        "Expected coffee emoji for term: #{term}"
    end
  end

  test "favorite_icon_for returns taco emoji for taco-related terms" do
    taco_terms = [
      "taco", "Taco", "TACO", "tacos",
      "mexican", "Mexican food",
      "burrito", "quesadilla"
    ]
    
    taco_terms.each do |term|
      assert_equal "🌮", favorite_icon_for(term),
        "Expected taco emoji for term: #{term}"
    end
  end

  test "favorite_icon_for returns pizza emoji for pizza-related terms" do
    pizza_terms = [
      "pizza", "Pizza", "PIZZA",
      "pizzeria", "pizza place",
      "italian", "Italian restaurant",
      "pepperoni", "pepperoni pizza"
    ]
    
    pizza_terms.each do |term|
      assert_equal "🍕", favorite_icon_for(term),
        "Expected pizza emoji for term: #{term}"
    end
  end

  test "favorite_icon_for returns default heart for unmatched terms" do
    unmatched_terms = [
      "random", "bookstore", "pharmacy",
      "gas station", "bank", "library"
    ]
    
    unmatched_terms.each do |term|
      assert_equal "❤️", favorite_icon_for(term),
        "Expected default heart emoji for term: #{term}"
    end
  end

  test "favorite_icon_for returns default heart for blank or nil terms" do
    assert_equal "❤️", favorite_icon_for("")
    assert_equal "❤️", favorite_icon_for(nil)
    assert_equal "❤️", favorite_icon_for("   ")
  end

  test "favorite_icon_for handles additional food categories" do
    test_cases = {
      "burger" => "🍔",
      "hamburger" => "🍔",
      "fast food" => "🍔",
      "sushi" => "🍣",
      "japanese" => "🍣",
      "ramen" => "🍣",
      "chinese" => "🥢",
      "dim sum" => "🥢",
      "ice cream" => "🍰",
      "dessert" => "🍰",
      "bakery" => "🍰",
      "bar" => "🍺",
      "beer" => "🍺",
      "brewery" => "🍺",
      "wine" => "🍷",
      "vineyard" => "🍷",
      "restaurant" => "🍽️",
      "dining" => "🍽️"
    }
    
    test_cases.each do |term, expected_icon|
      assert_equal expected_icon, favorite_icon_for(term),
        "Expected #{expected_icon} for term: #{term}"
    end
  end

  test "favorite_icon_states_for returns correct filled and unfilled states" do
    # Test coffee
    states = favorite_icon_states_for("coffee", false)
    assert_equal "☕️", states[:filled]
    assert_equal "☕", states[:unfilled]
    assert_equal "☕", states[:current]
    
    states = favorite_icon_states_for("coffee", true)
    assert_equal "☕️", states[:filled]
    assert_equal "☕", states[:unfilled]
    assert_equal "☕️", states[:current]
    
    # Test taco
    states = favorite_icon_states_for("taco", false)
    assert_equal "🌮", states[:filled]
    assert_equal "🥙", states[:unfilled]
    assert_equal "🥙", states[:current]
    
    states = favorite_icon_states_for("taco", true)
    assert_equal "🌮", states[:filled]
    assert_equal "🥙", states[:unfilled]
    assert_equal "🌮", states[:current]
    
    # Test pizza
    states = favorite_icon_states_for("pizza", false)
    assert_equal "🍕", states[:filled]
    assert_equal "🍽️", states[:unfilled]
    assert_equal "🍽️", states[:current]
    
    states = favorite_icon_states_for("pizza", true)
    assert_equal "🍕", states[:filled]
    assert_equal "🍽️", states[:unfilled]
    assert_equal "🍕", states[:current]
    
    # Test default case
    states = favorite_icon_states_for("random", false)
    assert_equal "❤️", states[:filled]
    assert_equal "🤍", states[:unfilled]
    assert_equal "🤍", states[:current]
    
    states = favorite_icon_states_for("random", true)
    assert_equal "❤️", states[:filled]
    assert_equal "🤍", states[:unfilled]
    assert_equal "❤️", states[:current]
  end

  test "favorite_button_classes_for returns appropriate CSS classes" do
    test_cases = {
      "coffee" => "favorite-btn favorite-coffee",
      "taco" => "favorite-btn favorite-taco",
      "pizza" => "favorite-btn favorite-pizza",
      "burger" => "favorite-btn favorite-burger",
      "sushi" => "favorite-btn favorite-sushi",
      "chinese" => "favorite-btn favorite-chinese",
      "dessert" => "favorite-btn favorite-dessert",
      "beer" => "favorite-btn favorite-beer",
      "wine" => "favorite-btn favorite-wine",
      "restaurant" => "favorite-btn favorite-restaurant",
      "random" => "favorite-btn favorite-default"
    }
    
    test_cases.each do |term, expected_classes|
      assert_equal expected_classes, favorite_button_classes_for(term),
        "Expected classes '#{expected_classes}' for term: #{term}"
    end
  end

  test "regex patterns are case insensitive" do
    # Test mixed case variations
    mixed_case_terms = {
      "Coffee Shop" => "☕️",
      "TACO BELL" => "🌮",
      "Pizza Hut" => "🍕",
      "Mexican Food" => "🌮",
      "Italian Restaurant" => "🍕",
      "Fast Food" => "🍔"
    }
    
    mixed_case_terms.each do |term, expected_icon|
      assert_equal expected_icon, favorite_icon_for(term),
        "Expected #{expected_icon} for mixed case term: #{term}"
    end
  end

  test "regex patterns handle word boundaries correctly" do
    # Test that patterns match within larger phrases
    phrase_tests = {
      "best coffee in town" => "☕️",
      "authentic taco place" => "🌮",
      "wood fired pizza restaurant" => "🍕",
      "local burger joint" => "🍔",
      "fresh sushi bar" => "🍣",
      "traditional chinese cuisine" => "🥢",
      "craft beer brewery" => "🍺",
      "fine wine selection" => "🍷"
    }
    
    phrase_tests.each do |phrase, expected_icon|
      assert_equal expected_icon, favorite_icon_for(phrase),
        "Expected #{expected_icon} for phrase: #{phrase}"
    end
  end

  test "helper methods handle edge cases gracefully" do
    # Test with empty strings and whitespace
    assert_equal "❤️", favorite_icon_for("")
    assert_equal "❤️", favorite_icon_for("   ")
    assert_equal "❤️", favorite_icon_for("\t\n")
    
    # Test states with empty terms
    states = favorite_icon_states_for("", false)
    assert_equal "❤️", states[:filled]
    assert_equal "🤍", states[:unfilled]
    assert_equal "🤍", states[:current]
    
    # Test CSS classes with empty terms
    assert_equal "favorite-btn favorite-default", favorite_button_classes_for("")
  end
end
