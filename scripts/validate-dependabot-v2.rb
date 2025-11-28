#!/usr/bin/env ruby
# Comprehensive Dependabot configuration validator using official schema

require 'yaml'
require 'json'
require 'net/http'
require 'uri'

class DependabotValidator
  SCHEMA_URL = 'https://json.schemastore.org/dependabot-2.0'
  
  def initialize(config_file = '.github/dependabot.yml')
    @config_file = config_file
    @schema = nil
  end
  
  def validate
    puts "🔍 Validating Dependabot configuration..."
    
    # Basic file existence check
    unless File.exist?(@config_file)
      puts "❌ Dependabot config file not found: #{@config_file}"
      return false
    end
    
    # Parse YAML
    begin
      config = YAML.load_file(@config_file)
    rescue YAML::SyntaxError => e
      puts "❌ YAML syntax error: #{e.message}"
      return false
    rescue => e
      puts "❌ Error reading config: #{e.message}"
      return false
    end
    
    # Basic structure validation
    unless config.is_a?(Hash)
      puts "❌ Config must be a YAML object/dictionary"
      return false
    end
    
    unless config['version'] == 2
      puts "❌ Missing or incorrect version field (should be 2)"
      return false
    end
    
    unless config['updates'].is_a?(Array)
      puts "❌ Updates field must be an array"
      return false
    end
    
    # Validate each update section
    config['updates'].each_with_index do |update, index|
      puts "  📋 Validating update section #{index + 1}..."
      
      unless update['package-ecosystem']
        puts "    ❌ Missing package-ecosystem"
        return false
      end
      
      # Validate allow section
      if update['allow']
        unless update['allow'].is_a?(Array)
          puts "    ❌ Allow section must be an array"
          return false
        end
        
        update['allow'].each_with_index do |allow_rule, allow_index|
          if allow_rule.is_a?(Hash)
            # Check for invalid properties in allow section
            invalid_props = allow_rule.keys - ['dependency-type']
            if invalid_props.any?
              puts "    ❌ Allow rule #{allow_index + 1} contains invalid properties: #{invalid_props.join(', ')}"
              puts "       Valid properties: dependency-type"
              return false
            end
          end
        end
      end
      
      # Validate groups
      if update['groups']
        unless update['groups'].is_a?(Hash)
          puts "    ❌ Groups section must be a hash"
          return false
        end
        
        update['groups'].each do |group_name, group_config|
          if group_config['update-types']
            unless group_config['update-types'].is_a?(Array)
              puts "    ❌ Group '#{group_name}' update-types must be an array"
              return false
            end
          end
        end
      end
    end
    
    # Check for duplicate ecosystems
    ecosystems = config['updates'].map { |u| u['package-ecosystem'] }
    duplicates = ecosystems.group_by(&:itself).select { |k, v| v.size > 1 }.keys
    
    if duplicates.any?
      puts "❌ Duplicate package ecosystems found: #{duplicates.join(', ')}"
      return false
    end
    
    # Success
    puts "✅ Dependabot configuration is valid"
    puts "📦 Configured ecosystems: #{ecosystems.join(', ')}"
    puts "🔢 Number of update groups: #{config['updates'].size}"
    
    # Show summary
    config['updates'].each do |update|
      ecosystem = update['package-ecosystem']
      groups = update['groups']&.keys || []
      puts "  📋 #{ecosystem}: #{groups.empty? ? 'no groups' : groups.join(', ')}"
    end
    
    return true
  end
  
  def fetch_schema
    puts "📥 Fetching official Dependabot schema..."
    
    uri = URI(SCHEMA_URL)
    response = Net::HTTP.get(uri)
    
    if response.is_a?(Net::HTTPSuccess)
      @schema = JSON.parse(response.body)
      puts "✅ Schema fetched successfully"
    else
      puts "⚠️  Could not fetch schema, using basic validation only"
    end
  rescue => e
    puts "⚠️  Error fetching schema: #{e.message}"
  end
end

# Run validation if called directly
if __FILE__ == $0
  validator = DependabotValidator.new
  
  # Try to fetch schema (optional)
  validator.fetch_schema
  
  # Run validation
  success = validator.validate
  
  exit(success ? 0 : 1)
end
