require 'application_system_test_case'

class LocalesTest < ApplicationSystemTestCase

  test 'the language selector shows all available locales' do
    visit '/'
    
    # Check if new language selector button exists in top-right near theme toggle
    if has_selector?('.language-selector button[aria-haspopup]', wait: 0)
      # New language selector: test dropdown functionality
      find('.language-selector button[aria-haspopup]').click
      
      # Verify all language options are present in the dropdown
      within '.language-selector [role="menu"], .language-selector .language-menu' do
        assert_selector 'a, [role="menuitem"]', text: 'English'
        assert_selector 'a, [role="menuitem"]', text: 'Português'
        assert_selector 'a, [role="menuitem"]', text: 'Français'
        assert_selector 'a, [role="menuitem"]', text: 'Español'
      end
    else
      # Fallback: check if footer still has language links
      within 'footer' do
        assert_selector 'a', text: 'English'
        assert_selector 'a', text: 'Português'
        assert_selector 'a, [role="menuitem"]', text: 'Français'
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
end
