# frozen_string_literal: true

require 'test_helper'

class CoffeeshopsCardTest < ActionView::TestCase
  setup do
    @coffeeshop = coffeeshops(:one)
    view.stubs(:logged_in?).returns(false)
    view.stubs(:coffeeshop_path).returns('/coffeeshops/1')
  end

  test 'coffeeshop card uses Tailwind dark classes to avoid Materialize CSS conflicts' do
    render partial: 'coffeeshops/coffeeshop', locals: {
      coffeeshop: @coffeeshop,
      search_query: 'coffee',
    }

    assert_includes rendered, 'coffeeshop-card',
                    'Expected rendered card to include coffeeshop-card class'

    # Require dark:bg-slate-900 specifically to prevent regression.
    # bg-base utility doesn't work because Materialize's .card { background-color: #fff }
    # overrides it due to CSS specificity. Tailwind dark: classes avoid this conflict.
    assert_includes rendered, 'dark:bg-slate-900',
                    'Expected card to use dark:bg-slate-900 (not bg-base) to avoid Materialize CSS override'
    
    assert_includes rendered, 'dark:text-white',
                    'Expected card to use dark:text-white for proper text contrast in dark mode'
  end
end
