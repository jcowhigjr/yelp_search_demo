require 'application_system_test_case'

class MobileViewTest < ApplicationSystemTestCase
  test 'navbar renders mobile layout at small viewport' do
    visit new_search_path
    resize_to_mobile_viewport

    assert_selector '.sidenav-trigger', visible: true
    assert_selector '#nav-mobile', visible: false

    find('.sidenav-trigger').trigger('click')
    assert_selector '#mobile-demo', visible: true, wait: 5
    assert_selector '#mobile-demo a', text: I18n.t('views.searches.new')
  end
end
