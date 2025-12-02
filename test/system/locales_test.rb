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

  test 'language selector interaction switches to French locale' do
    # Visit homepage and verify initial English locale
    visit '/'
    
    # Verify initial page loads with html[lang="en"]
    assert_equal 'en', page.find('html')['lang'], "Expected html[lang='en'] on initial load"
    
    # Verify English heading is present (New Search page)
    assert_selector 'h2', text: 'New Search'
    
    # Verify English search placeholder
    assert_selector "input[placeholder='Search for coffee shops...']"
    
    # Locate and click the French language selector in footer
    within 'footer .language-nav' do
      # Find the French language link by text content
      french_link = find('a', text: 'Français')
      # Click and wait for page to reload
      french_link.click
    end
    
    # Wait for page to finish loading after navigation
    # Check the URL to confirm we navigated to /fr
    assert_current_path '/fr'
    
    # Verify page updates to html[lang="fr"] after language switch
    assert_equal 'fr', page.find('html')['lang'], "Expected html[lang='fr'] after clicking French selector"
    
    # Verify French search placeholder is displayed
    assert_selector "input[placeholder='Rechercher des cafés...']", wait: 5
    
    # Verify French language link has active class
    within 'footer .language-nav' do
      french_link = find('a', text: 'Français')
      assert french_link[:class].include?('language-nav__link--active'), "Expected French link to have active class"
    end
  end
end
