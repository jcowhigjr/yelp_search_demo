require_relative '../build_revision'

namespace :build_revision do
  desc 'Capture Heroku build source revision without runtime Git or credentials'
  task :capture do
    BuildRevision.capture(ENV['SOURCE_COMMIT'])
  end
end

# Heroku's Ruby build runs assets:precompile; capture before compilation.
Rake::Task['assets:precompile'].enhance(['build_revision:capture'])
