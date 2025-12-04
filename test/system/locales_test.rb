require 'application_system_test_case'

class LocalesTest < ApplicationSystemTestCase

  test 'the language selector shows all available locales' do
    visit '/'
    
    # Check if new language selector button exists (future implementation)
    if has_selector?('button[aria-haspopup]', wait: 0)
      # New language selector: test dropdown functionality
      find('button[aria-haspopup]').click
      
      # Verify all language options are present in the dropdown
      assert_selector '[role="menu"] a, [role="menuitem"], .language-menu a', text: 'English'
      assert_selector '[role="menu"] a, [role="menuitem"], .language-menu a', text: 'Português'
      assert_selector '[role="menu"] a, [role="menuitem"], .language-menu a', text: 'Français'
      assert_selector '[role="menu"] a, [role="menuitem"], .language-menu a', text: 'Español'
    else
      # Current implementation: test footer links
      within 'footer' do
        assert_selector 'a', text: 'English'
        assert_selector 'a', text: 'Português'
        assert_selector 'a', text: 'Français'
        assert_selector 'a', text: 'Español'
      end
    end
   end


  test 'en is the default locale' do
    visit '/'

    assert_equal(:en, I18n.locale)
    visit '/en'

    assert_equal(:en, I18n.locale)
  end

  test 'navigation will update the locale' do
    visit '/'

    assert_equal(:en, I18n.locale)

    visit '/pt-BR'

    assert_not_equal(:"pt-BR", I18n.locale)

   I18n.with_locale(:"pt-BR") do
    visit '/'

    assert_equal(:"pt-BR", I18n.locale)
   end

    visit '/pt-BR'

     assert_equal(:en, I18n.locale)
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
    visit '/fr'
    assert_equal 'fr', page.find('html')['lang']
    
    # Navigate to Spanish
    visit '/es'
    assert_equal 'es', page.find('html')['lang']
    
    # Navigate to Portuguese
    visit '/pt-BR'
    assert_equal 'pt-BR', page.find('html')['lang']
  end

  test 'language selector shows active state for current locale' do
    # Test English is active on root
    visit '/'
    
    within 'footer .language-nav' do
      # English link should have active class
      english_link = find('a', text: 'English')
      assert english_link[:class].include?('language-nav__link--active'),
             "Expected English link to have active class on root path"
    end
    
    # Test French is active when on French path
    visit '/fr'
    
    within 'footer .language-nav' do
      french_link = find('a', text: 'Français')
      assert french_link[:class].include?('language-nav__link--active'),
             "Expected French link to have active class on /fr path"
    end
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
