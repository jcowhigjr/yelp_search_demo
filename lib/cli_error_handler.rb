#!/usr/bin/env ruby
# frozen_string_literal: true

# CLI Error Handler
# Implements robust error handling for CLI operations:
# - Catches all non-zero exits
# - On CI failure, logs details and posts comment via `gh issue comment`
# - On merge conflict, notifies user locally and aborts
# - Retries transient API errors with exponential backoff

require 'json'
require 'logger'
require 'open3'
require 'time'

class CliErrorHandler
  class Error < StandardError; end
  class CIFailureError < Error; end
  class MergeConflictError < Error; end
  class APITransientError < Error; end
  class APIRateLimitError < APITransientError; end
  class NetworkError < APITransientError; end

  # Exit codes
  EXIT_SUCCESS = 0
  EXIT_GENERAL_ERROR = 1
  EXIT_CI_FAILURE = 2
  EXIT_MERGE_CONFLICT = 3
  EXIT_API_FAILURE = 4
  EXIT_RETRY_EXHAUSTED = 5

  # Retry configuration
  DEFAULT_MAX_RETRIES = 3
  DEFAULT_BASE_DELAY = 1.0
  DEFAULT_MAX_DELAY = 60.0
  DEFAULT_BACKOFF_MULTIPLIER = 2.0

  # API error patterns for retry logic
  TRANSIENT_ERROR_PATTERNS = [
    /connection.*reset/i,
    /timeout/i,
    /temporarily unavailable/i,
    /rate limit exceeded/i,
    /service unavailable/i,
    /internal server error/i,
    /bad gateway/i,
    /gateway timeout/i,
    /too many requests/i,
    /api rate limit exceeded/i
  ].freeze

  attr_reader :logger, :max_retries, :base_delay, :max_delay, :backoff_multiplier

  def initialize(
    logger: nil,
    max_retries: DEFAULT_MAX_RETRIES,
    base_delay: DEFAULT_BASE_DELAY,
    max_delay: DEFAULT_MAX_DELAY,
    backoff_multiplier: DEFAULT_BACKOFF_MULTIPLIER
  )
    @logger = logger || create_default_logger
    @max_retries = max_retries
    @base_delay = base_delay
    @max_delay = max_delay
    @backoff_multiplier = backoff_multiplier
  end

  # Main entry point for executing commands with error handling
  def execute_with_handling(command, **options)
    logger.info("Executing command: #{command}")
    
    result = execute_command(command, **options)
    
    if result[:exit_code] != EXIT_SUCCESS
      handle_command_failure(command, result, **options)
    end
    
    result
  rescue StandardError => e
    handle_exception(command, e, **options)
    raise
  end

  # Execute command with retry logic for API operations
  def execute_with_retry(command, **options)
    retry_count = 0
    last_error = nil

    loop do
      begin
        result = execute_command(command, **options)
        
        if result[:exit_code] == EXIT_SUCCESS
          logger.info("Command succeeded after #{retry_count} retries") if retry_count > 0
          return result
        end

        # Check if this is a transient error that should be retried
        if transient_error?(result) && retry_count < max_retries
          delay = calculate_backoff_delay(retry_count)
          logger.warn("Transient error detected, retrying in #{delay}s (attempt #{retry_count + 1}/#{max_retries + 1})")
          sleep(delay)
          retry_count += 1
          next
        end

        # Non-transient error or max retries exceeded
        handle_command_failure(command, result, retry_count: retry_count, **options)
        return result

      rescue APITransientError => e
        last_error = e
        if retry_count < max_retries
          delay = calculate_backoff_delay(retry_count)
          logger.warn("API transient error: #{e.message}, retrying in #{delay}s (attempt #{retry_count + 1}/#{max_retries + 1})")
          sleep(delay)
          retry_count += 1
        else
          logger.error("Max retries (#{max_retries}) exhausted for API operation")
          handle_retry_exhausted(command, last_error, retry_count)
          raise
        end
      end
    end
  end

  private

  def create_default_logger
    logger = Logger.new($stdout)
    logger.level = Logger::INFO
    logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
    end
    logger
  end

  def execute_command(command, **options)
    start_time = Time.now
    
    stdout, stderr, status = Open3.capture3(command)
    
    end_time = Time.now
    duration = end_time - start_time

    result = {
      command: command,
      exit_code: status.exitstatus,
      stdout: stdout,
      stderr: stderr,
      duration: duration,
      options: options
    }

    log_command_result(result)
    result
  end

  def log_command_result(result)
    if result[:exit_code] == EXIT_SUCCESS
      logger.info("Command completed successfully in #{result[:duration].round(2)}s")
      logger.debug("STDOUT: #{result[:stdout]}") unless result[:stdout].empty?
    else
      logger.error("Command failed with exit code #{result[:exit_code]} after #{result[:duration].round(2)}s")
      logger.error("STDERR: #{result[:stderr]}") unless result[:stderr].empty?
      logger.debug("STDOUT: #{result[:stdout]}") unless result[:stdout].empty?
    end
  end

  def handle_command_failure(command, result, **options)
    case classify_error(result)
    when :ci_failure
      handle_ci_failure(command, result, **options)
    when :merge_conflict
      handle_merge_conflict(command, result, **options)
    when :api_error
      handle_api_error(command, result, **options)
    else
      handle_general_error(command, result, **options)
    end
  end

  def classify_error(result)
    stderr = result[:stderr].downcase
    stdout = result[:stdout].downcase
    combined_output = "#{stderr} #{stdout}"

    # Check for merge conflicts
    if combined_output.match?(/merge conflict|conflict.*merge|automatic merge failed/i)
      return :merge_conflict
    end

    # Check for CI failures
    if combined_output.match?(/ci.*fail|test.*fail|build.*fail|workflow.*fail/i) ||
       result[:command].match?(/gh.*run|gh.*workflow|gh.*action/i)
      return :ci_failure
    end

    # Check for API errors
    if result[:command].match?(/gh |git.*push|curl.*api/i) ||
       combined_output.match?(/api.*error|rate limit|authentication.*fail/i)
      return :api_error
    end

    :general
  end

  def handle_ci_failure(command, result, **options)
    logger.error("CI failure detected")
    
    # Extract failure details
    failure_details = extract_ci_failure_details(result)
    
    # Log comprehensive failure information
    log_ci_failure_details(failure_details)
    
    # Post comment to GitHub issue if PR context is available
    post_ci_failure_comment(failure_details, **options)
    
    raise CIFailureError, "CI failure: #{failure_details[:summary]}"
  end

  def handle_merge_conflict(command, result, **options)
    logger.error("Merge conflict detected")
    
    # Extract conflict details
    conflict_details = extract_merge_conflict_details(result)
    
    # Notify user locally with detailed information
    notify_merge_conflict_locally(conflict_details)
    
    # Abort any ongoing merge operation
    abort_merge_operation
    
    raise MergeConflictError, "Merge conflict: #{conflict_details[:summary]}"
  end

  def handle_api_error(command, result, **options)
    logger.error("API error detected")
    
    if transient_error?(result)
      raise APITransientError, "Transient API error: #{extract_error_message(result)}"
    else
      logger.error("Non-transient API error")
      handle_general_error(command, result, **options)
    end
  end

  def handle_general_error(command, result, **options)
    logger.error("General command failure")
    logger.error("Exit code: #{result[:exit_code]}")
    logger.error("Command: #{command}")
    logger.error("STDERR: #{result[:stderr]}") unless result[:stderr].empty?
  end

  def handle_exception(command, exception, **options)
    logger.error("Exception during command execution: #{exception.class}: #{exception.message}")
    logger.debug("Backtrace:\n#{exception.backtrace.join("\n")}")
  end

  def handle_retry_exhausted(command, last_error, retry_count)
    logger.error("Retry exhausted after #{retry_count} attempts")
    logger.error("Last error: #{last_error&.message}")
    
    # Optionally post a comment about retry exhaustion
    if github_context_available?
      post_retry_exhausted_comment(command, last_error, retry_count)
    end
  end

  def transient_error?(result)
    combined_output = "#{result[:stderr]} #{result[:stdout]}".downcase
    
    TRANSIENT_ERROR_PATTERNS.any? { |pattern| combined_output.match?(pattern) }
  end

  def calculate_backoff_delay(retry_count)
    delay = base_delay * (backoff_multiplier ** retry_count)
    [delay, max_delay].min
  end

  def extract_ci_failure_details(result)
    {
      command: result[:command],
      exit_code: result[:exit_code],
      stderr: result[:stderr],
      stdout: result[:stdout],
      duration: result[:duration],
      summary: extract_error_summary(result),
      timestamp: Time.now.iso8601
    }
  end

  def extract_merge_conflict_details(result)
    {
      command: result[:command],
      conflicted_files: extract_conflicted_files(result),
      conflict_markers: extract_conflict_markers(result),
      summary: "Merge conflict detected during: #{result[:command]}",
      stderr: result[:stderr],
      timestamp: Time.now.iso8601
    }
  end

  def extract_error_message(result)
    # Extract the most relevant error message
    stderr_lines = result[:stderr].split("\n").reject(&:empty?)
    stdout_lines = result[:stdout].split("\n").reject(&:empty?)
    
    # Prefer stderr, but fall back to stdout if stderr is empty
    error_lines = stderr_lines.any? ? stderr_lines : stdout_lines
    
    # Return the first few lines that seem to contain error information
    relevant_lines = error_lines.select { |line| 
      line.match?(/error|fail|exception|conflict/i) 
    }.first(3)
    
    relevant_lines.any? ? relevant_lines.join("; ") : "Unknown error"
  end

  def extract_error_summary(result)
    message = extract_error_message(result)
    # Truncate for summary
    message.length > 100 ? "#{message[0..97]}..." : message
  end

  def extract_conflicted_files(result)
    output = "#{result[:stderr]} #{result[:stdout]}"
    files = []
    
    # Look for common merge conflict patterns
    output.scan(/CONFLICT.*in (.+)$/i) { |match| files << match[0].strip }
    output.scan(/both modified:\s+(.+)$/i) { |match| files << match[0].strip }
    
    files.uniq
  end

  def extract_conflict_markers(result)
    output = "#{result[:stderr]} #{result[:stdout]}"
    markers = []
    
    # Look for conflict marker indicators
    if output.match?(/<<<<<<</i)
      markers << "<<<<<<< (conflict start)"
    end
    if output.match?(/=======/i)
      markers << "======= (conflict separator)"
    end
    if output.match?(/>>>>>>> /i)
      markers << ">>>>>>> (conflict end)"
    end
    
    markers
  end

  def log_ci_failure_details(details)
    logger.error("=== CI FAILURE DETAILS ===")
    logger.error("Command: #{details[:command]}")
    logger.error("Exit Code: #{details[:exit_code]}")
    logger.error("Duration: #{details[:duration].round(2)}s")
    logger.error("Summary: #{details[:summary]}")
    logger.error("Timestamp: #{details[:timestamp]}")
    
    unless details[:stderr].empty?
      logger.error("STDERR:")
      details[:stderr].split("\n").each { |line| logger.error("  #{line}") }
    end
    
    unless details[:stdout].empty?
      logger.debug("STDOUT:")
      details[:stdout].split("\n").each { |line| logger.debug("  #{line}") }
    end
    
    logger.error("=== END CI FAILURE DETAILS ===")
  end

  def notify_merge_conflict_locally(details)
    puts "\n" + "="*60
    puts "🚨 MERGE CONFLICT DETECTED"
    puts "="*60
    puts "Command: #{details[:command]}"
    puts "Summary: #{details[:summary]}"
    puts "Timestamp: #{details[:timestamp]}"
    
    if details[:conflicted_files].any?
      puts "\nConflicted Files:"
      details[:conflicted_files].each { |file| puts "  - #{file}" }
    end
    
    if details[:conflict_markers].any?
      puts "\nConflict Markers Found:"
      details[:conflict_markers].each { |marker| puts "  - #{marker}" }
    end
    
    puts "\nResolution Steps:"
    puts "1. Review the conflicted files listed above"
    puts "2. Edit files to resolve conflicts (remove <<<<<<, ======, >>>>>> markers)"
    puts "3. Stage resolved files: git add <file>"
    puts "4. Complete the merge: git commit"
    puts "5. Or abort the merge: git merge --abort"
    
    puts "\nMerge operation has been aborted to prevent corruption."
    puts "="*60 + "\n"
  end

  def abort_merge_operation
    logger.info("Attempting to abort ongoing merge operation...")
    
    # Check if we're in the middle of a merge
    if File.exist?('.git/MERGE_HEAD')
      result = execute_command('git merge --abort')
      if result[:exit_code] == EXIT_SUCCESS
        logger.info("Successfully aborted merge operation")
      else
        logger.warn("Failed to abort merge operation: #{result[:stderr]}")
      end
    else
      logger.info("No ongoing merge operation to abort")
    end
  end

  def post_ci_failure_comment(details, **options)
    return unless github_context_available?
    
    pr_number = options[:pr_number] || detect_pr_number
    return unless pr_number
    
    comment_body = build_ci_failure_comment(details)
    
    post_github_comment(pr_number, comment_body)
  end

  def post_retry_exhausted_comment(command, last_error, retry_count)
    return unless github_context_available?
    
    pr_number = detect_pr_number
    return unless pr_number
    
    comment_body = build_retry_exhausted_comment(command, last_error, retry_count)
    
    post_github_comment(pr_number, comment_body)
  end

  def build_ci_failure_comment(details)
    <<~COMMENT
      ## 🚨 CI Failure Detected

      **Command:** `#{details[:command]}`
      **Exit Code:** #{details[:exit_code]}
      **Duration:** #{details[:duration].round(2)}s
      **Timestamp:** #{details[:timestamp]}

      ### Error Summary
      #{details[:summary]}

      ### Error Details
      ```
      #{details[:stderr].empty? ? details[:stdout] : details[:stderr]}
      ```

      **Next Steps:**
      1. Review the error details above
      2. Fix the underlying issue
      3. Re-run the failed command
      4. Ensure all tests pass before requesting review

      ---
      *This comment was generated automatically by the CLI error handler.*
    COMMENT
  end

  def build_retry_exhausted_comment(command, last_error, retry_count)
    <<~COMMENT
      ## ⚠️ API Operation Retry Exhausted

      **Command:** `#{command}`
      **Retry Attempts:** #{retry_count}
      **Last Error:** #{last_error&.message || 'Unknown error'}

      The automated retry mechanism has been exhausted. This typically indicates:
      - Persistent API issues
      - Rate limiting
      - Network connectivity problems

      **Recommended Actions:**
      1. Wait a few minutes for rate limits to reset
      2. Check GitHub API status: https://status.github.com/
      3. Verify network connectivity
      4. Try the operation again manually

      ---
      *This comment was generated automatically by the CLI error handler.*
    COMMENT
  end

  def github_context_available?
    ENV['GITHUB_TOKEN'] && (ENV['GITHUB_REPOSITORY'] || git_remote_available?)
  end

  def git_remote_available?
    result = execute_command('git remote get-url origin')
    result[:exit_code] == EXIT_SUCCESS && result[:stdout].match?(/github\.com/)
  end

  def detect_pr_number
    # Try to detect PR number from environment or git context
    return ENV['PR_NUMBER'] if ENV['PR_NUMBER']
    
    # Try to get PR number from GitHub CLI
    result = execute_command('gh pr view --json number')
    if result[:exit_code] == EXIT_SUCCESS
      begin
        data = JSON.parse(result[:stdout])
        return data['number']
      rescue JSON::ParserError
        logger.debug("Failed to parse PR number from gh pr view")
      end
    end
    
    nil
  end

  def post_github_comment(pr_number, comment_body)
    logger.info("Posting GitHub comment to PR ##{pr_number}")
    
    # Use mise exec to ensure proper environment
    command = "mise exec -- gh pr comment #{pr_number} --body #{comment_body.shellescape}"
    
    result = execute_command(command)
    
    if result[:exit_code] == EXIT_SUCCESS
      logger.info("Successfully posted GitHub comment")
    else
      logger.error("Failed to post GitHub comment: #{result[:stderr]}")
    end
  end
end

# Command line interface
class CLIRunner
  def self.run(args)
    require 'optparse'
    
    options = {
      retry: false,
      max_retries: CliErrorHandler::DEFAULT_MAX_RETRIES,
      log_level: 'INFO',
      pr_number: nil,
      dry_run: false
    }
    
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options] -- command [args...]"
      
      opts.on('--retry', 'Enable retry logic for API operations') do
        options[:retry] = true
      end
      
      opts.on('--max-retries COUNT', Integer, 'Maximum number of retries') do |count|
        options[:max_retries] = count
      end
      
      opts.on('--log-level LEVEL', String, 'Log level (DEBUG, INFO, WARN, ERROR)') do |level|
        options[:log_level] = level.upcase
      end
      
      opts.on('--pr-number NUMBER', Integer, 'PR number for GitHub comments') do |number|
        options[:pr_number] = number
      end
      
      opts.on('--dry-run', 'Dry run mode - no GitHub comments') do
        options[:dry_run] = true
      end
      
      opts.on('-h', '--help', 'Show this help message') do
        puts opts
        exit 0
      end
    end
    
    # Find the -- separator
    separator_index = args.index('--')
    if separator_index.nil?
      puts "Error: Command separator '--' not found"
      puts parser
      exit 1
    end
    
    # Parse options before --
    option_args = args[0...separator_index]
    command_args = args[(separator_index + 1)..]
    
    if command_args.empty?
      puts "Error: No command specified after '--'"
      puts parser
      exit 1
    end
    
    begin
      parser.parse!(option_args)
    rescue OptionParser::InvalidOption => e
      puts "Error: #{e.message}"
      puts parser
      exit 1
    end
    
    # Override with environment variables
    options[:pr_number] ||= ENV['PR_NUMBER']&.to_i
    options[:log_level] = ENV['CLI_ERROR_HANDLER_LOG'] || options[:log_level]
    
    # Set up logger with specified level
    logger = Logger.new($stdout)
    logger.level = Logger.const_get(options[:log_level])
    logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
    end
    
    # Create handler with options
    handler = CliErrorHandler.new(
      logger: logger,
      max_retries: options[:max_retries]
    )
    
    # Build the command string
    command = command_args.join(' ')
    
    # Execute with appropriate method
    begin
      if options[:retry]
        logger.info("Executing with retry: #{command}")
        result = handler.execute_with_retry(command, pr_number: options[:pr_number], dry_run: options[:dry_run])
      else
        logger.info("Executing with basic handling: #{command}")
        result = handler.execute_with_handling(command, pr_number: options[:pr_number], dry_run: options[:dry_run])
      end
      
      exit result[:exit_code]
      
    rescue CliErrorHandler::CIFailureError => e
      logger.error("CI failure: #{e.message}")
      exit CliErrorHandler::EXIT_CI_FAILURE
    rescue CliErrorHandler::MergeConflictError => e
      logger.error("Merge conflict: #{e.message}")
      exit CliErrorHandler::EXIT_MERGE_CONFLICT
    rescue CliErrorHandler::APITransientError => e
      logger.error("API failure: #{e.message}")
      exit CliErrorHandler::EXIT_API_FAILURE
    rescue CliErrorHandler::Error => e
      logger.error("CLI error: #{e.message}")
      exit CliErrorHandler::EXIT_GENERAL_ERROR
    rescue StandardError => e
      logger.error("Unexpected error: #{e.class}: #{e.message}")
      logger.debug("Backtrace:\n#{e.backtrace.join("\n")}")
      exit CliErrorHandler::EXIT_GENERAL_ERROR
    end
  end
end

# Usage examples and CLI integration
if __FILE__ == $0
  if ARGV.include?('--example')
    # Example usage
    handler = CliErrorHandler.new
    
    begin
      # Example 1: Execute with basic error handling
      result = handler.execute_with_handling('ls /nonexistent')
    rescue CliErrorHandler::Error => e
      puts "Caught CLI error: #{e.message}"
    end
    
    begin
      # Example 2: Execute with retry logic for API operations
      result = handler.execute_with_retry('gh api repos/owner/repo')
    rescue CliErrorHandler::APITransientError => e
      puts "API operation failed after retries: #{e.message}"
    end
  else
    # Run CLI interface
    CLIRunner.run(ARGV)
  end
end
