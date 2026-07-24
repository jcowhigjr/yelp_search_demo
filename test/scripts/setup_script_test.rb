require 'test_helper'

require 'fileutils'
require 'open3'
require 'tmpdir'

class SetupScriptTest < ActiveSupport::TestCase
  def setup
    @temporary_directory = Dir.mktmpdir('setup-script-test')
    @app_root = File.join(@temporary_directory, 'app')
    @fake_bin = File.join(@temporary_directory, 'fake-bin')
    @call_log = File.join(@temporary_directory, 'mise-calls.log')

    FileUtils.mkdir_p(File.join(@app_root, 'bin'))
    FileUtils.mkdir_p(@fake_bin)
    FileUtils.cp(Rails.root.join('bin/setup'), File.join(@app_root, 'bin/setup'))
    FileUtils.chmod('+x', File.join(@app_root, 'bin/setup'))
    write_fake_mise
  end

  def teardown
    FileUtils.remove_entry(@temporary_directory)
  end

  test 'preview setup ignores a project lefthook binstub' do
    project_lefthook = File.join(@app_root, 'bin/lefthook')
    write_executable(
      project_lefthook,
      <<~BASH,
        #!/usr/bin/env bash
        echo "project lefthook binstub should not run" >&2
        exit 42
      BASH
    )

    stdout, stderr, status = run_setup(
      path: "#{File.join(@app_root, 'bin')}:#{@fake_bin}:/usr/bin:/bin",
    )

    assert_predicate status, :success?, stdout + stderr
    assert_includes stdout, 'Ignoring project lefthook binstub'
    assert_includes stdout, 'Lefthook not found; skipping Git hooks installation'
    assert_not_includes mise_calls, 'lefthook install'
  end

  test 'local setup installs a standalone lefthook after dependencies' do
    standalone_lefthook = File.join(@fake_bin, 'lefthook')
    write_executable(
      standalone_lefthook,
      <<~BASH,
        #!/usr/bin/env bash
        exit 0
      BASH
    )

    stdout, stderr, status = run_setup(path: "#{@fake_bin}:/usr/bin:/bin")

    assert_predicate status, :success?, stdout + stderr
    dependency_index = mise_calls.index('exec -- bundle check')
    lefthook_index = mise_calls.index("exec -- #{standalone_lefthook} install")

    assert_not_nil dependency_index, mise_calls
    assert_not_nil lefthook_index, mise_calls
    assert_operator dependency_index, :<, lefthook_index
  end

  test 'setup still fails when dependency installation fails' do
    stdout, stderr, status = run_setup(
      path: "#{@fake_bin}:/usr/bin:/bin",
      extra_env: { 'FAIL_BUNDLE' => '1' },
    )

    assert_not_predicate status, :success?
    assert_includes stdout + stderr, 'bundle install (after bundle check failed)'
    assert_not_includes mise_calls, 'lefthook install'
  end

  private

  def run_setup(path:, extra_env: {})
    env = {
      'CI' => 'false',
      'PATH' => path,
      'SETUP_CALL_LOG' => @call_log,
      'SETUP_SKIP_ENV' => 'true',
      'SKIP_CLEAN' => 'true',
    }.merge(extra_env)

    Open3.capture3(
      env,
      '/bin/bash',
      File.join(@app_root, 'bin/setup'),
      '--skip-server',
      chdir: @app_root,
    )
  end

  def write_fake_mise
    write_executable(
      File.join(@fake_bin, 'mise'),
      <<~'BASH',
        #!/usr/bin/env bash
        printf '%s\n' "$*" >> "$SETUP_CALL_LOG"

        if [ "$*" = "exec -- bundle exec lefthook --version" ]; then
          exit 1
        fi

        if [ "${FAIL_BUNDLE:-0}" = "1" ]; then
          if [ "$*" = "exec -- bundle check" ] || [ "$*" = "exec -- bundle install" ]; then
            exit 1
          fi
        fi

        exit 0
      BASH
    )
  end

  def write_executable(path, contents)
    File.write(path, contents)
    FileUtils.chmod('+x', path)
  end

  def mise_calls
    File.exist?(@call_log) ? File.read(@call_log) : ''
  end
end
