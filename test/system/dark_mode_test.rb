require 'application_system_test_case'

class DarkModeTest < ApplicationSystemTestCase
  test 'coffeeshop titles follow the theme text color variable' do
    # Minimal search flow to render coffee results
    visit new_search_path
    fill_in 'search[query]', with: 'coffee'
    first('button[type="submit"]').click

    # Wait for at least one coffeeshop card to appear
    assert_selector '.coffeeshop-card', wait: 10
    assert_selector '.card-title a', wait: 10

    force_dark_mode!
    set_theme_text('#123456')

    card_color =
      page.evaluate_script('window.getComputedStyle(document.querySelector(".card-title a")).color')

    assert_equal 'rgb(18, 52, 86)', card_color

    capture_search_results if capture_dark_mode?

    click_more_info_safely

    assert_selector '.page-name', wait: 10

    set_theme_text('#123456')

    page_name_color =
      page.evaluate_script('window.getComputedStyle(document.querySelector(".page-name")).color')

    assert_equal 'rgb(18, 52, 86)', page_name_color

    shop_info_shadow =
      page.evaluate_script('window.getComputedStyle(document.querySelector(".shop-info")).boxShadow')

    assert_equal 'none', shop_info_shadow

    capture_show_page if capture_dark_mode?
  end

  private

  def capture_dark_mode?
    ENV['CAPTURE_DARK_MODE'] == 'true'
  end

  def force_dark_mode!
    page.execute_script(<<~JS)
      const root = document.documentElement;
      root.style.setProperty('--color-bg', '#18181b');
      root.style.setProperty('--color-primary', '#223556');
      root.style.setProperty('--color-primary-dark', '#16243a');
      document.body.style.backgroundColor = '#18181b';
    JS
  end

  def set_theme_text(color)
    page.execute_script("document.documentElement.style.setProperty('--color-text', '#{color}')")
  end

  def capture_search_results
    set_theme_text('#ffffff')
    page.save_screenshot(Rails.root.join('tmp/dark-mode-search.png'), full: true)
  end

  def capture_show_page
    set_theme_text('#ffffff')
    page.save_screenshot(Rails.root.join('tmp/dark-mode-show.png'), full: true)
  end
end
