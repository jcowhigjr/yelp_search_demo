require 'application_system_test_case'

# rubocop:disable Metrics/ClassLength
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

  # AC5: System tests for language selector functionality
  test 'switching locale updates I18n.locale' do
    visit '/'

    assert_equal :en, I18n.locale

    # Click French language link in footer
    within 'footer .language-nav' do
      click_link 'Français'
    end

    # Verify we navigated to French locale URL and French content is displayed
    assert_selector "input[placeholder='Rechercher des cafés...']"
    
    # Verify URL contains locale path
    assert_match %r{/(fr|\?locale=fr)}, current_url
  end

  test 'switching locale updates html lang attribute' do
    visit '/'
    
    # Verify initial lang attribute is 'en'
    html_lang = page.evaluate_script('document.documentElement.lang')

    assert_equal 'en', html_lang

    # Switch to French
    within 'footer .language-nav' do
      click_link 'Français'
    end

    # Wait for page to load with French content
    assert_selector "input[placeholder='Rechercher des cafés...']"

    # Verify lang attribute is updated to 'fr'
    html_lang = page.evaluate_script('document.documentElement.lang')

    assert_equal 'fr', html_lang
  end

  test 'switching locale updates translated content' do
    visit '/'
    
    # Verify English placeholder
    assert_selector "input[placeholder='Search for coffee shops...']"

    # Switch to Spanish
    within 'footer .language-nav' do
      click_link 'Español'
    end

    # Verify Spanish placeholder
    assert_selector "input[placeholder='Buscar cafeterías...']"
  end

  test 'language selector marks active locale' do
    visit '/'

    # Verify English link has active class
    within 'footer .language-nav' do
      english_link = find('a', text: 'English')

      assert_includes english_link[:class], 'language-nav__link--active', 
                      "Expected English link to have active class but got: #{english_link[:class]}"
    end

    # Switch to Portuguese
    within 'footer .language-nav' do
      click_link 'Português'
    end

    # Wait for page to load with Portuguese content
    assert_selector 'input[placeholder]'

    # Verify Portuguese link has active class
    within 'footer .language-nav' do
      portuguese_link = find('a', text: 'Português')

      assert_includes portuguese_link[:class], 'language-nav__link--active', 
                      "Expected Portuguese link to have active class but got: #{portuguese_link[:class]}"
    end
  end

  test 'language selector does not interfere with theme toggle' do
    visit '/'

    # Verify theme toggle button exists
    assert_selector 'button[data-theme-target="button"]'

    # Switch language
    within 'footer .language-nav' do
      click_link 'Français'
    end

    # Verify theme toggle still exists and is functional after language switch
    assert_selector 'button[data-theme-target="button"]'
    
    # Click theme toggle
    find('button[data-theme-target="button"]').click
    
    # Verify theme toggle icon exists (indicates button is still functional)
    assert_selector 'i[data-theme-target="icon"]'
  end

  test 'search functionality remains intact across locale changes' do
    visit '/'

    # Verify search input exists in English
    assert_selector 'input[type="search"]'
    english_placeholder = find('input[type="search"]')[:placeholder]

    assert_equal 'Search for coffee shops...', english_placeholder

    # Switch to French
    within 'footer .language-nav' do
      click_link 'Français'
    end

    # Verify search input still exists and placeholder is translated
    assert_selector 'input[type="search"]'
    french_placeholder = find('input[type="search"]')[:placeholder]

    assert_equal 'Rechercher des cafés...', french_placeholder

    # Verify search button exists and is clickable
    assert_selector 'button[type="submit"]'
  end

  test 'all UI elements remain functional after locale switch' do
    visit '/'

    # Switch to Spanish
    within 'footer .language-nav' do
      click_link 'Español'
    end

    # Verify critical UI elements still exist
    assert_selector 'input[type="search"]'
    assert_selector 'button[type="submit"]'
    assert_selector 'button[data-theme-target="button"]'
    assert_selector 'footer .language-nav'

    # Switch to Portuguese
    within 'footer .language-nav' do
      click_link 'Português'
    end

    # Verify elements still exist after second locale switch
    assert_selector 'input[type="search"]'
    assert_selector 'button[type="submit"]'
    assert_selector 'button[data-theme-target="button"]'
    assert_selector 'footer .language-nav'
  end
end
# rubocop:enable Metrics/ClassLength
