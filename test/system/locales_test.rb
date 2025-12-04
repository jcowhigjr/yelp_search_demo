require 'application_system_test_case'

class LocalesTest < ApplicationSystemTestCase

  test 'the language selector shows all available locales' do
    visit '/'

    find('.language-selector__button').click

    assert_selector '.language-menu__item', text: 'English'
    assert_selector '.language-menu__item', text: 'Português (Brasil)'
    assert_selector '.language-menu__item', text: 'Français'
    assert_selector '.language-menu__item', text: 'Español'
  end


  test 'en is the default locale' do
    visit '/'

    assert_equal 'en', page.find('html')[:lang]
  end

  test 'navigation will update the locale' do
    visit '/'

    find('.language-selector__button').click
    click_link 'Français'
    assert_selector("html[lang='fr']")

    find('.language-selector__button').click
    click_link 'English'
    assert_selector("html[lang='en']")
  end

  test 'search placeholder is correctly translated' do
    # Test root path (should default to English)
    visit '/'

    assert_selector "input[placeholder='Search for coffee shops...']"

    # Test explicit English path
    visit '/en'

    assert_selector "input[placeholder='Search for coffee shops...']"

    # Test Spanish
    visit '/es'

    assert_selector "input[placeholder='Buscar cafeterías...']"

    # Test French
    visit '/fr'

    assert_selector "input[placeholder='Rechercher des cafés...']"
  end

  test 'language selector updates html lang attribute' do
    visit '/'
    
    # Verify initial lang attribute
    assert_equal 'en', page.find('html')['lang']
    
    # Navigate to French
    find('.language-selector__button').click
    click_link 'Français'
    assert_selector("html[lang='fr']")
    
    # Navigate to Spanish
    find('.language-selector__button').click
    click_link 'Español'
    assert_selector("html[lang='es']")
    
    # Navigate to Portuguese
    find('.language-selector__button').click
    click_link 'Português (Brasil)'
    assert_selector("html[lang='pt-BR']")
  end

  test 'language selector shows active state for current locale' do
    # Test English is active on root
    visit '/'
    
    find('.language-selector__button').click
    assert_selector '.language-menu__item--active', text: 'English'
    find('.language-selector__button').click # close the menu
    
    # Test French is active when on French path
    visit '/fr'
    
    find('.language-selector__button').click
    assert_selector '.language-menu__item--active', text: 'Français'
  end

  test 'search functionality works across all locales' do
    # Test search works in English
    visit '/'
    fill_in 'search_query', with: 'coffee'
    # Verify placeholder is in English
    search_input = find('#search_query')
    assert_equal 'Search for coffee shops...', search_input[:placeholder]
    
    # Test search works in French
    visit '/fr'
    fill_in 'search_query', with: 'café'
    # Verify placeholder is in French
    search_input = find('#search_query')
    assert_equal 'Rechercher des cafés...', search_input[:placeholder]
    
    # Test search works in Spanish
    visit '/es'
    fill_in 'search_query', with: 'café'
    # Verify placeholder is in Spanish
    search_input = find('#search_query')
    assert_equal 'Buscar cafeterías...', search_input[:placeholder]
  end
end
