# Set default locale to English
I18n.default_locale = :en

# Load all locales from config/locales/*.{rb,yml}
I18n.load_path += Rails.root.glob("config/locales/**/*.{rb,yml}")

# Available locales for our application
I18n.available_locales = [:en, :es, :fr, :'pt-BR', :th]

# Raise errors for missing translations in development and test
# if Rails.env.local?
#   I18n.exception_handler = lambda do |exception, locale, key, _options|
#     # Only raise errors for non-Thai locales during testing
#     if exception.is_a?(I18n::MissingTranslation) && locale != :th
#       raise "Missing translation: #{key}"
#     end
#   end
#   end

# Force Thai locale to load
Rails.application.config.after_initialize do
  I18n.available_locales = I18n.available_locales + [:th] unless I18n.available_locales.include?(:th)
end
