# frozen_string_literal: true

require 'test_helper'

class CoffeeshopsCardTest < ActionView::TestCase
  setup do
    @coffeeshop = coffeeshops(:one)
    view.stubs(:logged_in?).returns(false)
    view.stubs(:coffeeshop_path).returns('/coffeeshops/1')
  end

  test 'coffeeshop card has required class for CSS variable dark mode' do
    render partial: 'coffeeshops/coffeeshop', locals: {
      coffeeshop: @coffeeshop,
      search_query: 'coffee',
    }

    assert_includes rendered, 'coffeeshop-card',
                    'Expected rendered card to include coffeeshop-card class'

    # Dark mode works via .coffeeshop-card.card CSS rule in coffeeshops.scss
    # which uses CSS variables (--color-bg, --color-text) that respond to prefers-color-scheme.
    # This is necessary because:
    # 1. Materialize's .card { background-color: #fff } overrides Tailwind utilities
    # 2. Tailwind v4 dark: classes generate invalid nested @media syntax
    # 3. .coffeeshop-card.card has higher specificity than .card alone
    assert_includes rendered, 'class="card large coffeeshop-card"',
                    'Expected card to have both card and coffeeshop-card classes for CSS override'
  end
end
