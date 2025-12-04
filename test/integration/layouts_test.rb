require 'test_helper'

class LayoutsTest < ActionDispatch::IntegrationTest

  test '#root_path returns the correct path' do
    assert_equal('/', static_home_path)
  end

  test 'defaults to English translation' do
    get static_home_path

    assert_select 'h2', 'New Search'
  end

  test 'renders translated versions of the markdown' do
    get static_home_path(locale: 'pt-BR')

    assert_select 'h2', 'Nova pesquisa'
  end

  test 'language selector renders all locales' do
    get static_home_path

    assert_select '.language-selector'
    assert_select '.language-menu__item', I18n.available_locales.count
  end

  test 'language links have correct hrefs for each locale' do
    I18n.available_locales.each do |locale|
      get static_home_path(locale: locale)
      
      # Verify links to all locales exist
      I18n.available_locales.each do |link_locale|
        expected_href = link_locale == I18n.default_locale ? '/' : "/#{link_locale}"
        assert_select ".language-menu__item[href='#{expected_href}']", minimum: 1
      end
    end
  end

  test 'language selector marks current locale as active' do
    get static_home_path(locale: 'fr')

    assert_select '.language-menu__item--active', text: /Français/
  end

  test 'html lang attribute matches current locale' do
    I18n.available_locales.each do |locale|
      get static_home_path(locale: locale)
      
      assert_select "html[lang='#{locale}']"
    end
  end

  test 'search placeholder is translated based on locale' do
    # Test English
    get static_home_path(locale: 'en')
    assert_select "input[placeholder='Search for coffee shops...']"
    
    # Test French
    get static_home_path(locale: 'fr')
    assert_select "input[placeholder='Rechercher des cafés...']"
    
    # Test Spanish
    get static_home_path(locale: 'es')
    assert_select "input[placeholder='Buscar cafeterías...']"
  end
end
