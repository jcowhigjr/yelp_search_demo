# frozen_string_literal: true

# RED phase: These tests validate the system test helper contracts.
# Each test targets a specific adversarial review finding.

require 'application_system_test_case'

class TestInfrastructureTest < ApplicationSystemTestCase
  setup do
    stub_yelp_api_request('coffee')
    @user = users(:one)
  end

  # Finding 3: mobile_viewport? must return a boolean, not swallow unrelated errors
  test 'mobile_viewport? returns a boolean after page load' do
    visit '/'
    result = mobile_viewport?
    assert_includes [true, false], result, 'mobile_viewport? must return true or false'
  end

  # Finding 4: navigate_via_nav must fail clearly when not logged in
  test 'navigate_via_nav raises when navbar is absent (not logged in)' do
    visit '/'
    error = assert_raises(RuntimeError) do
      navigate_via_nav('New Search')
    end
    assert_match(/not logged in|no .* nav/i, error.message)
  end

  # Finding 4 (positive case): navigate_via_nav works when logged in
  test 'navigate_via_nav reaches target page when logged in' do
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    navigate_via_nav('New Search')
    assert_current_path '/searches/new'
  end

  # Finding 5: click_more_info_safely must not raise NoMethodError
  test 'click_more_info_safely navigates to a coffeeshop without NoMethodError' do
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    visit new_search_path
    assert_selector 'form.search-bar-container', wait: 10
    fill_in 'search[query]', with: 'coffee'
    find('button[aria-label="Search"]').click
    wait_for_search_results

    # Must not raise NoMethodError — only Capybara::ElementNotFound is acceptable
    click_more_info_safely
    assert_current_path %r{^/coffeeshops/\d+}
  end

  # Finding 6 & 7: wait_for_search_results must require actual card content
  test 'wait_for_search_results confirms coffeeshop cards are present' do
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    visit new_search_path
    assert_selector 'form.search-bar-container', wait: 10
    fill_in 'search[query]', with: 'coffee'
    find('button[aria-label="Search"]').click
    wait_for_search_results

    # After wait_for_search_results, actual cards must exist (not just containers)
    assert_selector '.coffeeshop-card', minimum: 1
  end

  # Finding 7: perform_search must leave us on a page with actual results
  test 'perform_search ends with visible result cards' do
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    perform_search('coffee')
    assert_selector '.coffeeshop-card', minimum: 1
  end

  # Finding 8: open_mobile_sidenav must only click visible triggers
  test 'open_mobile_sidenav opens the sidenav when logged in at mobile viewport' do
    skip 'Only meaningful at mobile viewport' unless mobile_viewport_configured?

    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    visit new_search_path
    open_mobile_sidenav
    assert_selector '#mobile-demo', visible: true
  end

  private

  def mobile_viewport_configured?
    # Check if driver is configured with mobile-sized viewport
    page.evaluate_script('window.innerWidth') <= 600
  rescue StandardError
    true
  end
end
