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

  test 'clicking French language selector switches locale and updates html lang attribute' do
    # Start on English homepage
    visit '/'
    
    # STEP 1: Assert initial state - English (en)
    # Assert html[lang="en"] attribute on page load
    assert_equal 'en', page.find('html')['lang'], "Expected html[lang='en'] on initial page load"
    
    # Assert English heading is present
    assert_selector 'h1', text: 'COFFEE NEAR YOU!'
    assert_selector 'p', text: 'Find the best coffee shops in your area'
    
    # Assert English search placeholder
    assert_selector "input[placeholder='Search for coffee shops...']"
    
    # STEP 2: Switch to French locale
    # Locate and click the French language selector in the footer
    within 'footer .language-nav' do
      click_link 'Français'
    end
    
    # STEP 3: Assert French state after language switch
    # Assert html[lang="fr"] attribute after switching to French
    assert_equal 'fr', page.find('html')['lang'], "Expected html[lang='fr'] after switching to French"
    
    # Assert French search placeholder is displayed (this IS translated via i18n)
    assert_selector "input[placeholder='Rechercher des cafés...']"
    
    # STEP 4: Assert translated headings (or document current hardcoded state)
    # Note: The headings "COFFEE NEAR YOU!" and "Find the best coffee shops in your area" 
    # are currently hardcoded in English and not translated via i18n. 
    # This test documents the current state. When translations are added, update these assertions
    # to check for French headings like:
    #   assert_selector 'h1', text: 'CAFÉ PRÈS DE CHEZ VOUS!'
    #   assert_selector 'p', text: 'Trouvez les meilleurs cafés de votre région'
    assert_selector 'h1', text: 'COFFEE NEAR YOU!'
    assert_selector 'p', text: 'Find the best coffee shops in your area'
    
    # STEP 5: Verify active language indicator
    # Verify the French language link has the active class
    within 'footer .language-nav' do
      assert_selector 'a.language-nav__link--active', text: 'Français'
    end
  end
end
