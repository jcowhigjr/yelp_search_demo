# config/initializers/flipper.rb

require 'flipper/adapters/pstore'

if ENV['FLIPPER_SPINNER_WHEEL']
  Flipper.add :decision_wheel
  Flipper.enable :decision_wheel
end

if ENV['FLIPPER_EARLY_ACCESS_PREVIEW']
  Flipper.add :early_access_preview
  Flipper.enable :early_access_preview
end
