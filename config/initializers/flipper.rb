# config/initializers/flipper.rb

require 'flipper/adapters/pstore'

unless Rails.env.test?
  if ENV['FLIPPER_SPINNER_WHEEL']
    Flipper.add :decision_wheel
    Flipper.enable :decision_wheel
  end
  # if ENV['FLIPPER_EARLY_ACCESS_PREVIEW']
  Flipper.add :early_access_preview
  Flipper.enable :early_access_preview
  # end
end

# Rails.logger.debug do "Flipper features after running intializer: #{Flipper.features.map do |f|
#  [f.key, f.enabled?] end.to_json}" end
