require_relative "boot"

require "rails/all"
require_relative "../lib/jitter/railtie"
require_relative "../lib/jitter/version"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Jitter
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Ensure Tailwind build directory is on the asset load path in all envs
    config.assets.paths << Rails.root.join("app/assets/builds")

    # Allow embedding in iframes for development previews (e.g., Windsurf, VS Code Simple Browser)
    if Rails.env.development?
      config.action_dispatch.default_headers['X-Frame-Options'] = 'ALLOWALL'
    end

    # Enable custom configurations
    config.jitter.compression_enabled = true
    config.jitter.locales_enabled = true

    # Application semantic version for error reporting / build identification
    config.x.app_version = Jitter::VERSION
  end
end
