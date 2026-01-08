# frozen_string_literal: true

require 'application_system_test_case'

class LoginTest < ApplicationSystemTestCase
  setup { @user = users(:one) }

  test 'I should login and see My Profile' do
    visit '/login'
    fill_in 'email', with: @user.email
    click_on 'Log In'
    fill_in 'Password', with: default_password
    click_on 'Log In'
    
    # In the new design, click directly on My Profile in desktop navigation
    # or open mobile sidenav first if in mobile test environment
    if ENV['CUPRITE'] == 'true'
      # Open mobile sidenav
      sidenav_trigger = find('.sidenav-trigger')
      sidenav_trigger.trigger('click')
      # Wait for mobile navigation content to be visible
      assert_selector '#mobile-demo', visible: true, wait: 5
      # Click My Profile in mobile navigation using trigger to avoid coordinate issues
      find('#mobile-demo a', text: 'My Profile').trigger('click')
    else
      # Desktop navigation - click directly
      click_on 'My Profile'
    end

    assert_text 'Your favorite spots:'
  end
end
