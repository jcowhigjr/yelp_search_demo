# frozen_string_literal: true

require 'test_helper'

class CoffeeshopsCardTest < ActionView::TestCase
  setup do
    @coffeeshop = coffeeshops(:one)
    view.stubs(:logged_in?).returns(false)
    view.stubs(:coffeeshop_path).returns('/coffeeshops/1')
  end

  test 'coffeeshop card keeps a dark-friendly background class' do
    render partial: 'coffeeshops/coffeeshop', locals: {
      coffeeshop: @coffeeshop,
      search_query: 'coffee',
    }

    assert_includes rendered, 'coffeeshop-card'

    has_dark_class = rendered.include?('bg-base') || rendered.include?('dark:bg-slate-900')

    assert has_dark_class,
           'Expected coffeeshop card to include bg-base or dark:bg-slate-900 for dark mode support'
  end
end
