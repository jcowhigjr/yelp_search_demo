# lib/gem_update.rb

def extract_gem_diff(diff)
  gem_name = diff.scan(/^\+ {4}([a-zA-Z0-9_-]+) \([0-9]+\.[0-9]+\.[0-9]+\)/).flatten.first
  gem_version = diff.scan(/^\+ {4}[a-zA-Z0-9_-]+ \(([0-9]+\.[0-9]+\.[0-9]+)\)/).flatten.first
  { gem_name:, gem_version: }
end

def update_gem(gem_name, gem_version, gemfile)
  if gem_name && gem_version
    Rails.logger.debug { "Updating gem: #{gem_name} to version: #{gem_version} in #{gemfile}" }
    command = "BUNDLE_GEMFILE=#{gemfile} bundle update #{gem_name}"
    Rails.logger.debug { "Executing command: #{command}" }  # Debugging line

    system(command)

  else
    Rails.logger.debug 'No gem version bump detected.'
    false  # Ensure it returns false when no gem is provided
  end
end
