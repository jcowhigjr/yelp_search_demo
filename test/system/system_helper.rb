# Load general RSpec Rails configuration
# require "rails_helper.rb"

# Load configuration files and helpers
Dir[File.join(__dir__, 'system/support/**/*.rb')].each do |file|
  require file
end
