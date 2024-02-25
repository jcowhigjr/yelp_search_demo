require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Jitter
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults Rails::VERSION::STRING.to_f

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.

    if Rails::VERSION::STRING >= '7.1'
      config.action_controller.raise_on_missing_callback_actions = true
      config.autoload_lib(ignore: %w[assets tasks])
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Set permitted locales
    config.i18n.available_locales = [:en, :es, :fr, :"pt-BR"]
    # Set default locale
    config.i18n.default_locale = :en

    # https://github.com/romanbsd/heroku-deflater/issues/54#issuecomment-803400481
    config.middleware.use Rack::Deflater
    config.middleware.use Rack::Brotli

  end
end
