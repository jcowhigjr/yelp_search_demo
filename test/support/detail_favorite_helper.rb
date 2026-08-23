module DetailFavoriteHelper
  def assert_detail_favorite_state(label)
    within "turbo-frame[id^='favorite_coffeeshop_']" do
      assert_selector 'button.favorite-btn'
      assert_selector 'span.sr-only', text: label, visible: :all
    end
  end

  def toggle_detail_favorite(before_label, after_label)
    assert_detail_favorite_state(before_label)
    within("turbo-frame[id^='favorite_coffeeshop_']") { click_button(class: 'favorite-btn') }

    assert_detail_favorite_state(after_label)
  end
end
