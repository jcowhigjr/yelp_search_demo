require 'application_system_test_case'

class LocalesTest < ApplicationSystemTestCase

  test 'the footer has a link to all available locales' do
    visit '/'
    within 'footer' do
      assert_selector 'a', text: 'English'
      assert_selector 'a', text: 'Português'
      assert_selector 'a', text: 'Français'
      assert_selector 'a', text: 'Español'
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
end
