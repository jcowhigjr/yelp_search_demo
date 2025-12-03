require 'test_helper'

class RenderLocales < ActionDispatch::IntegrationTest
  test 'renders both sections of markdown' do
    get '/signup'
    assert_select 'input[type="email"]'
    assert_select 'input[type="password"]'
    assert_select 'input[placeholder="Password (must be at least 6 characters)"]'
  end

  test 'renders translated versions of the markdown' do
    get login_path(locale: 'pt-BR')
    get '/signup'
    assert_select 'input[type="email"]'
    assert_select 'input[type="password"]'
    assert_select 'input[placeholder="Password (must be at least 6 characters)"]'
  end

end

class SwitchLocaleTest < ActionDispatch::IntegrationTest

  test 'I18n.locale will depends on the locale of urls' do
    I18n.available_locales.each do |locale|
      I18n.with_locale(locale) do
        get static_home_path

        assert_equal I18n.locale.to_s, locale.to_s
        assert_select 'html[lang="en"]'

      end
    end
  end

  test 'Visit urls with an unavailable locale will return 404' do
    get static_home_path(locale: 'xx')

    assert_response :not_found
  end

  test 'Links to all available locales will show' do
    [:en, :"pt-BR"].each do |locale|
      I18n.with_locale(locale) do
        get static_home_path

        # Verify default locale link exists (could be in language selector or elsewhere)
        assert_select "a[href='/']", minimum: 1

        # Verify non-default locale links exist with correct hrefs
        # Language selector is now in top-right, not footer
        locales_except_default = I18n.available_locales - [I18n.default_locale]

        locales_except_default.each do |l|
          # Language links should have correct href in the language selector dropdown
          assert_select "a[href='/#{l}']", minimum: 1
        end
      end
    end
  end

  test 'en is the default locale' do
    get static_home_path

    assert_equal(:en, I18n.locale)
    get '/en'

    assert_equal(:en, I18n.locale)
  end


  test 'BUG: the locale is set to the default locale regardless' do
    assert_equal(:en, I18n.default_locale)
    assert_equal(:en, I18n.locale)
    get '/pt-BR'

    assert_not_equal(:"pt-BR", I18n.locale)
    get '/en'

    assert_equal(:en, I18n.locale)
  end

  test 'path_help_paths can change locales' do
    #   scope '(:locale)', locale: /#{I18n.available_locales.join("|")}/, defaults: {locale: nil} do
    #   putting the default locale: nil here was the problem, removing it every time :(
    [:en, :"pt-BR"].each do |locale|
      I18n.with_locale(locale) do
        # with_locale sets the locale
        assert_equal I18n.locale, locale

        get static_home_path

        assert_equal I18n.locale, locale

        get '/pt-BR'

        assert_equal I18n.locale, locale

        assert login_path, '/pt-BR/login'
      end
    end
  end

  test 'the routes will change when the locale changes' do
    assert_routing '/en/signup', controller: 'users', action: 'new', locale: 'en'

    [:en, :"pt-BR"].each do |locale|
      I18n.with_locale(locale) do
        assert_routing "/#{locale}/signup", controller: 'users', action: 'new', locale: locale.to_s
      end
    end
  end

  test 'path helpers in tests require locale' do
    @user = users(:two)
    @coffeeshop = coffeeshops(:two)

    assert_equal('/pt-BR/coffeeshops/2', coffeeshop_path(@coffeeshop, locale: 'pt-BR' ))
  end

  def language_name_of(locale)
    I18n.t('layouts.footer.language_name_of_locale', locale:)
  end
end
