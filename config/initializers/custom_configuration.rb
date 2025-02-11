# rubocop:disable Metrics/BlockLength
Rails.application.config.after_initialize do
  # Host configurations
  if Rails.env.production?
    Rails.application.routes.default_url_options = {
      host: ENV["HOST"] || "#{ENV.fetch('HEROKU_APP_NAME', nil)}.herokuapp.com",
      locale: nil,
    }
    Rails.application.config.hosts << ENV.fetch("HOST", nil)
    Rails.application.config.hosts << "#{ENV.fetch('HEROKU_APP_NAME', nil)}.herokuapp.com"
  end

  # Locale configurations
  Rails.application.config.i18n.available_locales = [:en, :es, :fr, :"pt-BR"]
  Rails.application.config.i18n.default_locale = :en

  # Compression middleware
  unless Rails.application.config.middleware.include?(Rack::Deflater)
    Rails.application.config.middleware.use Rack::Deflater
  end

  unless Rails.application.config.middleware.include?(Rack::Brotli)
    Rails.application.config.middleware.use Rack::Brotli
  end
end
# rubocop:enable Metrics/BlockLength
