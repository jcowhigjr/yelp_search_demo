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


    # https://github.com/romanbsd/heroku-deflater/issues/54#issuecomment-803400481
    config.middleware.use Rack::Deflater,
      include: Rack::Mime::MIME_TYPES.select{|_k, v| v =~ /text|json|javascript/ }.values.uniq,
      if: lambda {|_env, _status, _headers, body| body.body.length > 512 }

    require 'rack/brotli'

    config.middleware.use Rack::Brotli,
      include: Rack::Mime::MIME_TYPES.select{|_k, v| v =~ /text|json|javascript/ }.values.uniq,
      if: lambda {|_env, _status, _headers, body| body.body.length > 512 },
      deflater: {
        quality: 1,
      }
      # https://github.com/denverstartupweek/dsw-site/pull/1104/files#diff-c1fd91cb1911a0512578b99f657554526f3e1421decdb9e908712beab57e10f9
    # Deflate assets per https://www.schneems.com/2017/11/08/80-smaller-rails-footprint-with-rack-deflate/
    config.middleware.insert_after ActionDispatch::Static, Rack::Deflater
  end
end
