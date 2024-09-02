require 'flipper'
# require 'flipper/adapters/memory'

Rails.application.configure do
  # Disable Flipper's built-in test helper.
  # It fails in CI and feature don't get activated.
  config.flipper.test_help = false
end

Flipper.configure do |flipper|
  # Still use recommended test setup with faster memory adapter:
  if Rails.env.test?
    # Use a shared Memory adapter for all tests. The adapter is instantiated
    # outside of the block so the same instance is returned in new threads.
    adapter = Flipper::Adapters::Memory.new
    flipper.adapter { adapter }
  end
end

# Don't enable features here, do it in the test setup
