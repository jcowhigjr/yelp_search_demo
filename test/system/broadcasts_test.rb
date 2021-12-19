require 'application_system_test_case'

class BroadcastsTest < ApplicationSystemTestCase
  setup { Coffeeshop.delete_all }
  # setup do
  #   @coffeeshop_one = coffeeshops(:one)
  # end
  # test 'Coffeeshop broadcasts Turbo Streams' do
  #   visit static_home_url
  #   fill_in('query', with: '30312')
  #   click_button('Search')
  #   @coffeeshop = Coffeeshop.first
  #   assert_text 'Coffeeshops'
  #   assert_broadcasts_text 'Coffeeshop Broadcast Test' do |text|
  #     @coffeeshop.update(name: text).broadcast_append_to(:coffeeshops)
  #   end
  # end

  # test 'New coffeeshops update the coffeeshop count with html' do
  #   visit static_home_url
  #   fill_in('query', with: '30312')
  #   click_button('Search')
  #   assert_text 'Coffeeshops'
  #   assert_difference "Coffeeshop.count", 1 do
  #     coffeeshop = Coffeeshop.create(name: 'A new coffeeshop')
  #     coffeeshop.broadcast_append_to(:coffeeshops)
  #   end
  # end

  # test "Users::Profile broadcasts Turbo Streams" do
  #   visit users_profiles_path

  #   assert_text "Users::Profiles"
  #   assert_broadcasts_text "Profile 1" do |text|
  #     Users::Profile.new(id: 1, name: text).broadcast_append_to(:users_profiles)
  #   end
  # end

  private

  def assert_broadcasts_text(text, wait: 5, &block)
    assert_no_text text
    perform_enqueued_jobs { block.call(text) }
    assert_text text, wait: wait
  end
end
