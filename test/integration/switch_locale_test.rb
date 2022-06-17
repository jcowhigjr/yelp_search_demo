require 'test_helper'

class SwitchLocaleTest < ActionDispatch::IntegrationTest
  test 'I18n.locale will depends on the locale of urls' do
    I18n.available_locales.each do |locale|
      I18n.with_locale(locale) do
        get static_home_path
        assert_equal I18n.locale.to_s, locale.to_s
      end
    end
  end

  test 'Visit urls with an unavailable locale will return 404' do
    assert_raises ActionController::RoutingError do
      get static_home_path(locale: 'xx')
    end
  end

  test 'Links to all available locales will show' do
    [:en, :"pt-BR"].each do |locale|
      I18n.with_locale(locale) do
        get static_home_path

        assert_select "a[href='/']", text: language_name_of(I18n.default_locale)

        locales_except_default = I18n.available_locales - [I18n.default_locale]
        locales_except_default.each do |l|
          assert_select "a[href='/#{l}']", text: language_name_of(l)
        end
      end
    end
  end

  def language_name_of(locale)
    I18n.t('layouts.footer.language_name_of_locale', locale:)
  end
end
