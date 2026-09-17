require 'test_helper'

require 'fileutils'
require 'json'
require 'open3'
require 'tmpdir'

# Executable coverage for scripts/auto-update-prs.sh, including the #2996
# regression: a queued auto-merge PR whose first mergeStateStatus snapshot is
# stale must be picked up by the bounded fresh-state recheck.
class AutoUpdatePrsTest < ActiveSupport::TestCase
  include GhStubHelpers
  include AutoUpdateStubHelpers

  SCRIPT = Rails.root.join('scripts/auto-update-prs.sh')

  def setup
    setup_gh_stub('fake_gh_auto_update_prs.sh')
  end

  def teardown
    teardown_gh_stub
  end

  test 'exits quietly when nothing is behind; cross-repo PRs are never touched' do
    prs([
      pr(number: 7, state: 'CLEAN'),
      pr(number: 12, state: 'BEHIND', 'isCrossRepository' => true),
    ])

    stdout, _stderr, status = run_script(SCRIPT)

    assert_predicate status, :success?, stdout
    assert_includes stdout, 'No open PRs behind develop.'
    assert_not_includes gh_calls, 'update-branch'
  end

  test 'updates a snapshot BEHIND PR and triggers CI without auto-merge' do
    prs([pr(number: 8, state: 'BEHIND', 'headRefOid' => 'sha-eight')])
    write_head(8, 'sha-eight')

    stdout, _stderr, status = run_script(SCRIPT)

    assert_predicate status, :success?, stdout
    assert_includes gh_calls, 'pulls/8/update-branch'
    assert_includes gh_calls, 'expected_head_sha=sha-eight'
    assert_not_includes gh_calls, 'pr merge'
    assert_includes gh_calls, 'workflow run main.yml'
  end

  test 'queued PR that turns BEHIND on fresh recheck is updated (issue #2996)' do
    prs([pr(number: 42, state: 'CLEAN', 'headRefOid' => 'sha-queued', 'autoMergeRequest' => AUTO_MERGE)])
    write_state_sequence(42, %w[UNKNOWN BEHIND])
    write_head(42, 'sha-queued')

    stdout, _stderr, status = run_script(SCRIPT)

    assert_predicate status, :success?, stdout
    assert_includes stdout, 'PR #42 reported BEHIND on fresh-state recheck'
    assert_includes gh_calls, 'pulls/42/update-branch'
    assert_includes gh_calls, 'expected_head_sha=sha-queued'
    assert_includes gh_calls, 'pr merge --auto --squash 42'
    assert_includes gh_calls, 'workflow run main.yml'
  end

  test 'queued PR that settles CLEAN on recheck is left alone' do
    prs([pr(number: 9, state: 'UNKNOWN', 'autoMergeRequest' => AUTO_MERGE)])
    write_state_sequence(9, %w[CLEAN])
    write_head(9, 'sha-9')

    stdout, _stderr, status = run_script(SCRIPT)

    assert_predicate status, :success?, stdout
    assert_includes stdout, 'PR #9 fresh state is CLEAN; no update needed.'
    assert_not_includes gh_calls, 'update-branch'
  end

  test 'fails loudly when the initial pr list fails' do
    prs([pr(number: 8, state: 'BEHIND')])

    stdout, _stderr, status = run_script(SCRIPT, 'GH_STUB_FAIL_PR_LIST' => '1')

    assert_not_predicate status, :success?
    assert_not_includes stdout, 'No open PRs behind develop.'
  end

  test 'a failed update-branch call is a visible failure' do
    prs([pr(number: 8, state: 'BEHIND')])
    write_head(8, 'sha-8')

    _stdout, _stderr, status = run_script(SCRIPT, 'GH_STUB_FAIL_UPDATE' => '1')

    assert_not_predicate status, :success?
    assert_includes gh_calls, 'update-branch'
  end

  test 'recheck exhaustion is a visible failure, not silent success' do
    prs([pr(number: 11, state: 'UNKNOWN', 'autoMergeRequest' => AUTO_MERGE)])
    write_state_sequence(11, %w[UNKNOWN UNKNOWN UNKNOWN])
    write_head(11, 'sha-11')

    stdout, _stderr, status = run_script(SCRIPT, 'AUTO_UPDATE_RECHECK_ATTEMPTS' => '2')

    assert_not_predicate status, :success?
    assert_includes stdout, '::error::PR #11 never reached a definitive merge state'
    assert_not_includes gh_calls, 'update-branch'
  end
end
