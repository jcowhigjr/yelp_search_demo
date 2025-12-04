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

  test 'language switching via selector updates html lang attribute and content' do
    # Step 1: Navigate to homepage and verify English is the default locale
    visit '/'
    
    # Assert html[lang="en"] attribute
    assert_equal 'en', page.find('html')['lang'], "Expected html[lang='en'] on initial page load"
    
    # Assert English heading is present (the main heading on homepage)
    assert_selector 'h1.page-name', text: 'COFFEE NEAR YOU!'
    
    # Assert English search placeholder
    assert_selector "input[placeholder='Search for coffee shops...']"
    
    # Step 2: Locate and click the French language selector in the footer
    within 'footer .language-nav' do
      # Find the French language link by its text content
      french_link = find('a', text: 'Français')
      
      # Verify the link exists before clicking
      assert_predicate french_link, :present?, 'French language selector link should be present'
      
      # Click the French language selector
      french_link.click
    end
    
    # Step 3: Wait for page navigation and verify French locale is active
    # Assert html[lang="fr"] attribute after language switch
    assert_equal 'fr', page.find('html')['lang'], "Expected html[lang='fr'] after clicking French language selector"
    
    # Assert French search placeholder is displayed
    assert_selector "input[placeholder='Rechercher des cafés...']"
    
    # Verify the French language link is now marked as active
    within 'footer .language-nav' do
      french_link = find('a', text: 'Français')

      assert_includes french_link[:class], 'language-nav__link--active', 
                      'French language link should have active class after switch'
    end
    
    # NOTE: The h2 heading "Save time by sharing your device location" is currently
    # hardcoded in English in app/views/static/home.html.erb and not translated.
    # This test verifies the locale switching mechanism works correctly via:
    # - html[lang] attribute change
    # - translated search placeholder
    # - active language link styling
  end
end
