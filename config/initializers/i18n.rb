# Set default locale to English
I18n.default_locale = :en

# Load all locales from config/locales/*.{rb,yml}
I18n.load_path += Rails.root.glob("config/locales/**/*.{rb,yml}")

# Available locales for our application
I18n.available_locales = [:en, :es, :fr, :'pt-BR', :th]

# Raise errors for missing translations in development and test
if Rails.env.local?
  I18n.exception_handler = lambda do |exception, _locale, key, _options|
    raise "Missing translation: #{key}" if exception.is_a?(I18n::MissingTranslation)
  end
end
