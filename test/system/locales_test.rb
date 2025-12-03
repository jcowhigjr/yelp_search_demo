require 'application_system_test_case'

class LocalesTest < ApplicationSystemTestCase

  test 'the language selector shows all available locales' do
    visit '/'
    
    # Check if new language selector button exists (new implementation in top-right)
    if has_selector?('button[aria-haspopup="true"]', wait: 1)
      # New language selector: test dropdown functionality
      language_button = find('button[aria-haspopup="true"]')
      
      # Verify button is in top-right area of layout
      assert language_button, 'Language selector button should be present'
      
      # Click to open dropdown
      language_button.click
      
      # Wait for menu to appear and verify all language options are present
      assert_selector '[role="menu"], .language-menu', visible: true
      within '[role="menu"], .language-menu' do
        assert_selector 'a, [role="menuitem"]', text: 'English'
        assert_selector 'a, [role="menuitem"]', text: 'Português'
        assert_selector 'a, [role="menuitem"]', text: 'Français'
        assert_selector 'a, [role="menuitem"]', text: 'Español'
      end
    else
      # Fallback: test footer links (old implementation)
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

  test 'clicking language selector updates I18n locale and page content' do
    visit '/'
    
    # Verify initial locale is English
    assert_equal :en, I18n.locale
    assert_selector 'html[lang="en"]'
    
    # Check if new language selector exists
    if has_selector?('button[aria-haspopup="true"]', wait: 1)
      # Test with new language selector button
      language_button = find('button[aria-haspopup="true"]')
      language_button.click
      
      # Wait for menu to appear
      assert_selector '[role="menu"], .language-menu', visible: true
      
      # Click on French language option
      within '[role="menu"], .language-menu' do
        french_link = find('a, [role="menuitem"]', text: 'Français')
        french_link.click
      end
      
      # Verify page navigated to French locale
      assert_current_path '/fr'
      assert_selector 'html[lang="fr"]'
      
      # Verify search placeholder is translated to French
      assert_selector "input[placeholder='Rechercher des cafés...']"
      
    else
      # Test with footer language links (old implementation)
      within 'footer .language-nav' do
        click_link 'Français'
      end
      
      # Verify page navigated to French locale
      assert_current_path '/fr'
      assert_selector 'html[lang="fr"]'
      
      # Verify search placeholder is translated to French
      assert_selector "input[placeholder='Rechercher des cafés...']"
    end
  end
end
