# # https://github.com/bullet-train-co/magic_test/wiki/Magic-Test-and-Cuprite
# # test/support/system/cuprite_setup.rb
# require "capybara/cuprite"

# Capybara.register_driver(:cuprite) do |app|
#   Capybara::Cuprite::Driver.new(
#     app,
#     **{
#       window_size: [1200, 800],
#       # See additional options for Dockerized environment in the respective section of this article
#       browser_options: {},
#       # Increase Chrome startup wait time (required for stable CI builds)
#       process_timeout: 10,
#       # Enable debugging capabilities
#       inspector: !ENV["HEADLESS"].in?(%w[n 0 no false]) && !ENV["MAGIC_TEST"].in?(%w[1]),
#       # Allow running Chrome in a headful mode by setting HEADLESS env
#       # var to a falsey value
#       headless: !ENV["HEADLESS"].in?(%w[n 0 no false]) && !ENV["MAGIC_TEST"].in?(%w[1]),
#     }
#   )
# end
