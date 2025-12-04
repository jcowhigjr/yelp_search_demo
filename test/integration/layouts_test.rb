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

  test 'language selector is present in footer' do
    get static_home_path

    assert_select 'footer .language-nav'
    assert_select 'footer .language-nav a', minimum: I18n.available_locales.count
  end

  test 'language links have correct hrefs for each locale' do
    I18n.available_locales.each do |locale|
      get static_home_path(locale: locale)
      
      # Verify links to all locales exist
      I18n.available_locales.each do |link_locale|
        expected_href = link_locale == I18n.default_locale ? '/' : "/#{link_locale}"
        assert_select "a[href='#{expected_href}']", minimum: 1
      end
    end
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
