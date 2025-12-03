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

  test 'navigation will update the locale and html lang attribute' do
    visit '/'
    assert_equal(:en, I18n.locale)
    assert_selector 'html[lang="en"]'

    visit '/pt-BR'
    assert_equal(:"pt-BR", I18n.locale)
    assert_selector 'html[lang="pt-BR"]'

    visit '/es'
    assert_equal(:es, I18n.locale)
    assert_selector 'html[lang="es"]'

    visit '/fr'
    assert_equal(:fr, I18n.locale)
    assert_selector 'html[lang="fr"]'
    
    # Visiting root should default back to English
    visit '/'
    assert_equal(:en, I18n.locale)
    assert_selector 'html[lang="en"]'
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
  
  test 'invalid locale returns 404' do
    visit '/xx'
    
    # Should show a 404 error page
    assert_text /not found|404/i
  end
end
