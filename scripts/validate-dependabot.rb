#!/usr/bin/env ruby
# Simple validation script for Dependabot configuration

require 'yaml'

def validate_dependabot_config
  config_file = '.github/dependabot.yml'
  
  unless File.exist?(config_file)
    puts "❌ Dependabot config file not found: #{config_file}"
    return false
  end
  
  begin
    config = YAML.load_file(config_file)
    
    # Check for basic structure
    unless config['version'] == 2
      puts "❌ Missing or incorrect version field"
      return false
    end
    
    unless config['updates'].is_a?(Array)
      puts "❌ Updates field is not an array"
      return false
    end
    
    # Check for duplicate ecosystems
    ecosystems = config['updates'].map { |u| u['package-ecosystem'] }
    duplicates = ecosystems.group_by(&:itself).select { |k, v| v.size > 1 }.keys
    
    if duplicates.any?
      puts "❌ Duplicate package ecosystems found: #{duplicates.join(', ')}"
      return false
    end
    
    puts "✅ Dependabot configuration is valid"
    puts "📦 Configured ecosystems: #{ecosystems.join(', ')}"
    puts "🔢 Number of update groups: #{config['updates'].size}"
    
    return true
    
  rescue YAML::SyntaxError => e
    puts "❌ YAML syntax error: #{e.message}"
    return false
  rescue => e
    puts "❌ Error reading config: #{e.message}"
    return false
  end
end

if __FILE__ == $0
  puts "🔍 Validating Dependabot configuration..."
  validate_dependabot_config
end
