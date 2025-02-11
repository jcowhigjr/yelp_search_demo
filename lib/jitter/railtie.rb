module Jitter
  class Railtie < Rails::Railtie
    config.before_configuration do |app|
      app.config.jitter = ActiveSupport::OrderedOptions.new
      app.config.jitter.compression_enabled = true
      app.config.jitter.locales_enabled = true
    end

    initializer 'jitter.configure_rails_initialization' do |app|
      if app.config.jitter.compression_enabled
        app.middleware.use Rack::Deflater
        app.middleware.use Rack::Brotli
      end

      if app.config.jitter.locales_enabled
        app.config.i18n.available_locales = [:en, :es, :fr, :"pt-BR"]
        app.config.i18n.default_locale = :en
      end
    end

    # Add custom rake tasks if needed
    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end
