# config/initializers/flipper.rb

require 'flipper'

Flipper.instance = nil # Ensure flipper gets reset

# Add the "early_access_preview" feature
Flipper.add :early_access_preview

# Add the "decision_wheel" feature
Flipper.add :decision_wheel


# Enable a feature for everyone
Flipper.enable :decision_wheel if ENV['FLIPPER_SPINNER_WHEEL']
Flipper.enable :early_access_preview if ENV['FLIPPER_EARLY_ACCESS_PREVIEW']
