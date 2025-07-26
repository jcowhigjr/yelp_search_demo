require "application_system_test_case"

class FavoritesIntegrationTest < ApplicationSystemTestCase
  include FavoritesHelper

  setup do
    @search = searches(:one)
  end

  test "favorite icons change based on search terms" do
    visit new_search_path
    
    # Test coffee search
    fill_in "search_query", with: "coffee"
    
    # Verify the helper returns the correct icon
    assert_equal "☕️", favorite_icon_for("coffee")
    
    # Test taco search
    fill_in "search_query", with: "taco"
    
    # Verify the helper returns the correct icon
    assert_equal "🌮", favorite_icon_for("taco")
    
    # Test pizza search
    fill_in "search_query", with: "pizza"
    
    # Verify the helper returns the correct icon
    assert_equal "🍕", favorite_icon_for("pizza")
  end

  test "favorite icon states toggle correctly" do
    # Test coffee states
    coffee_states = favorite_icon_states_for("coffee", false)
    assert_equal "☕️", coffee_states[:filled]
    assert_equal "☕", coffee_states[:unfilled]
    assert_equal "☕", coffee_states[:current]
    
    coffee_states_favorited = favorite_icon_states_for("coffee", true)
    assert_equal "☕️", coffee_states_favorited[:filled]
    assert_equal "☕", coffee_states_favorited[:unfilled]
    assert_equal "☕️", coffee_states_favorited[:current]
    
    # Test taco states
    taco_states = favorite_icon_states_for("taco", false)
    assert_equal "🌮", taco_states[:filled]
    assert_equal "🥙", taco_states[:unfilled]
    assert_equal "🥙", taco_states[:current]
    
    taco_states_favorited = favorite_icon_states_for("taco", true)
    assert_equal "🌮", taco_states_favorited[:filled]
    assert_equal "🥙", taco_states_favorited[:unfilled]
    assert_equal "🌮", taco_states_favorited[:current]
    
    # Test pizza states
    pizza_states = favorite_icon_states_for("pizza", false)
    assert_equal "🍕", pizza_states[:filled]
    assert_equal "🍽️", pizza_states[:unfilled]
    assert_equal "🍽️", pizza_states[:current]
    
    pizza_states_favorited = favorite_icon_states_for("pizza", true)
    assert_equal "🍕", pizza_states_favorited[:filled]
    assert_equal "🍽️", pizza_states_favorited[:unfilled]
    assert_equal "🍕", pizza_states_favorited[:current]
  end

  test "favorite button CSS classes are contextual" do
    # Test that CSS classes are generated correctly for different search terms
    assert_equal "favorite-btn favorite-coffee", favorite_button_classes_for("coffee")
    assert_equal "favorite-btn favorite-taco", favorite_button_classes_for("taco")
    assert_equal "favorite-btn favorite-pizza", favorite_button_classes_for("pizza")
    assert_equal "favorite-btn favorite-default", favorite_button_classes_for("random")
  end

  test "search form integration with dynamic icons" do
    visit new_search_path
    
    # Verify the search form is present
    assert_selector "form"
    assert_selector "input[name='search[query]']"
    
    # Test different search terms and verify helper behavior
    test_terms = ["coffee", "taco", "pizza", "burger", "sushi"]
    
    test_terms.each do |term|
      fill_in "search_query", with: term
      
      # Verify the helper returns appropriate icons
      icon = favorite_icon_for(term)
      assert_not_equal "❤️", icon, "Expected contextual icon for #{term}, got default heart"
      
      # Verify states work correctly
      states = favorite_icon_states_for(term, false)
      assert_not_nil states[:filled]
      assert_not_nil states[:unfilled]
      assert_not_nil states[:current]
      assert_equal states[:unfilled], states[:current]
      
      states_favorited = favorite_icon_states_for(term, true)
      assert_equal states_favorited[:filled], states_favorited[:current]
    end
  end

  test "case insensitive matching works in integration" do
    case_variations = [
      ["coffee", "Coffee", "COFFEE"],
      ["taco", "Taco", "TACO"],
      ["pizza", "Pizza", "PIZZA"]
    ]
    
    case_variations.each do |variations|
      expected_icon = favorite_icon_for(variations.first)
      
      variations.each do |variation|
        assert_equal expected_icon, favorite_icon_for(variation),
          "Case insensitive matching failed for #{variation}"
      end
    end
  end

  test "phrase matching works correctly" do
    phrase_tests = {
      "best coffee shop in town" => "☕️",
      "authentic mexican taco place" => "🌮",
      "wood fired pizza restaurant" => "🍕",
      "gourmet burger joint" => "🍔",
      "fresh sushi and japanese cuisine" => "🍣"
    }
    
    phrase_tests.each do |phrase, expected_icon|
      assert_equal expected_icon, favorite_icon_for(phrase),
        "Phrase matching failed for: #{phrase}"
    end
  end

  test "helper integration with search controller data" do
    # Test that the helper can work with search data from the controller
    visit new_search_path
    
    # Simulate search terms that would come from the search controller
    search_terms = ["coffee shop", "taco bell", "pizza hut", "random place"]
    
    search_terms.each do |term|
      icon = favorite_icon_for(term)
      states = favorite_icon_states_for(term, false)
      css_classes = favorite_button_classes_for(term)
      
      # Verify all helper methods work together
      assert_not_nil icon
      assert_not_nil states[:filled]
      assert_not_nil states[:unfilled]
      assert_not_nil states[:current]
      assert_includes css_classes, "favorite-btn"
      
      # Verify consistency between methods
      if icon == "❤️"
        assert_includes css_classes, "favorite-default"
      else
        assert_not_includes css_classes, "favorite-default"
      end
    end
  end
end
