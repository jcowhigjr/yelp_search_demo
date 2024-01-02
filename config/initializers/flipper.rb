# config/initializers/flipper.rb

require 'flipper'

Flipper.configure do |config|
  config.default do
    # Use memory adapter for simplicity
    adapter = Flipper::Adapters::Memory.new

    # Pass adapter to Flipper
    Flipper.new(adapter)
  end
end

# Add the "early_access_preview" feature
Flipper.add('early_access_preview')
Flipper.add('decision_wheel')

# Enable a feature for everyone
Flipper.enable :decision_wheel if ENV['FLIPPER_SPINNER_WHEEL']
Flipper.enable :early_access_preview if ENV['FLIPPER_EARLY_ACCESS_PREVIEW']
