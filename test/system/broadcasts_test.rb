require 'application_system_test_case'

class BroadcastsTest < ApplicationSystemTestCase
  setup { Coffeeshop.delete_all }

  private

  def assert_broadcasts_text(text, wait: 5)
    assert_no_text text
    perform_enqueued_jobs { yield(text) }

    assert_text text, wait:
  end
end
