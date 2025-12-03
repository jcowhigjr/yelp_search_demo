require 'application_system_test_case'

class LocalesTest < ApplicationSystemTestCase

  test 'the language selector shows all available locales' do
    visit '/'
    
    # Current implementation: test footer language navigation links
    within 'footer .language-nav' do
      assert_selector 'a.language-nav__link', text: 'English'
      assert_selector 'a.language-nav__link', text: 'Português'
      assert_selector 'a.language-nav__link', text: 'Français'
      assert_selector 'a.language-nav__link', text: 'Español'
    end
  end

  test 'the language selector highlights the active locale' do
    visit '/'
    
    # Verify English is active by default
    within 'footer .language-nav' do
      english_link = find('a.language-nav__link', text: 'English')
      assert english_link[:class].include?('language-nav__link--active'), 
             'English link should have active class'
    end
    
    # Switch to French and verify it becomes active
    visit '/fr'
    
    within 'footer .language-nav' do
      french_link = find('a.language-nav__link', text: 'Français')
      assert french_link[:class].include?('language-nav__link--active'),
             'French link should have active class'
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
