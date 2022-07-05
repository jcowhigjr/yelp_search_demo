require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Jitter
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]

    # Set permitted locales
    config.i18n.available_locales = [:en, :es, :fr, :"pt-BR"]
    # Set default locale
    config.i18n.default_locale = :en

    # config.middleware.use Rack::Deflater
    # config.middleware.use Rack::Brotli


    # config.assets.configure do |env|
    #   env.register_exporter %w[text/css application/javascript image/svg+xml], Sprockets::ExportersPack::BrotliExporter
    # end

    config.middleware.use Rack::Deflater,
      include: Rack::Mime::MIME_TYPES.select{|k, v| v =~ /text|json|javascript/ }.values.uniq,
      if: lambda {|env, status, headers, body| body.body.length > 512 }

    require 'rack/brotli'

    config.middleware.use Rack::Brotli,
      include: Rack::Mime::MIME_TYPES.select{|k, v| v =~ /text|json|javascript/ }.values.uniq,
      if: lambda {|env, status, headers, body| body.body.length > 512 },
      deflater: {
        quality: 1
      }

  end
end
