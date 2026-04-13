#!/usr/bin/env ruby

require 'optparse'
require 'open3'
require 'rubygems/version'

FILES = {
  'mise.toml' => [/^ruby = "(\d+\.\d+\.\d+)"$/],
  'Gemfile' => [/^ruby '(\d+\.\d+\.\d+)'$/],
  'Gemfile.next' => [/^ruby '(\d+\.\d+\.\d+)'$/],
}.freeze

options = {
  apply: false,
  latest_patch: false,
  target_version: nil,
}

OptionParser.new do |opts|
  opts.banner = 'Usage: ruby scripts/update_ruby_version.rb [options]'

  opts.on('--latest-patch', 'Resolve the latest patch release in the current Ruby minor') do
    options[:latest_patch] = true
  end

  opts.on('--version VERSION', 'Update to an explicit Ruby version') do |version|
    options[:target_version] = version
  end

  opts.on('--apply', 'Write changes back to the tracked files') do
    options[:apply] = true
  end
end.parse!

unless options[:latest_patch] ^ !options[:target_version].nil?
  abort('Specify exactly one of --latest-patch or --version VERSION')
end

def extract_version(path, pattern)
  File.foreach(path) do |line|
    match = line.match(pattern)
    return match[1] if match
  end
  raise "No Ruby version found in #{path}"
end

def resolve_latest_patch(current_version)
  major_minor = current_version.split('.').first(2).join('.')
  stdout, status = Open3.capture2('mise', 'ls-remote', 'ruby')
  raise 'Failed to list remote Ruby versions' unless status.success?

  candidates = stdout.lines
    .map(&:strip)
    .grep(/\A#{Regexp.escape(major_minor)}\.\d+\z/)
    .map { |version| Gem::Version.new(version) }

  raise "No remote Ruby versions found for #{major_minor}" if candidates.empty?

  candidates.max.to_s
end

def apply_version_updates(current_version, target_version, apply:)
  # rubocop:disable Metrics/BlockLength
  FILES.each do |path, patterns|
    original = File.read(path)
    updated = patterns.reduce(original) do |content, pattern|
      content.gsub(pattern) { |match| match.sub(current_version, target_version) }
    end

    raise "Expected to update #{path}, but no matching version string changed" if original == updated

    if apply
      File.write(path, updated)
      puts "Updated #{path}"
    else
      puts "Would update #{path}"
    end
  end
  # rubocop:enable Metrics/BlockLength
end

current_version = extract_version('mise.toml', FILES.fetch('mise.toml').first)
target_version = options[:target_version] || resolve_latest_patch(current_version)

unless Gem::Version.correct?(target_version)
  abort("Invalid target Ruby version: #{target_version}")
end

if Gem::Version.new(target_version).segments.first(2) != Gem::Version.new(current_version).segments.first(2)
  abort("Refusing to cross Ruby minor versions automatically (#{current_version} -> #{target_version})")
end

puts "Current Ruby version: #{current_version}"
puts "Target Ruby version:  #{target_version}"

if current_version == target_version
  puts 'Ruby version is already current.'
  exit 0
end

apply_version_updates(current_version, target_version, apply: options[:apply])
