require 'test_helper'

class DependabotWorkflowConfigurationTest < ActiveSupport::TestCase
  WORKFLOWS = Rails.root.join('.github/workflows')

  test 'one workflow owns Dependabot auto-merge eligibility' do
    queue_workflow = File.read(WORKFLOWS.join('auto-approve.yml'))

    assert_includes queue_workflow, 'pull_request_target:'
    assert_includes queue_workflow, 'version-update:semver-patch'
    assert_includes queue_workflow, 'version-update:semver-minor'
    assert_includes queue_workflow, "dependency-type == 'development'"
    assert_includes queue_workflow, 'gh pr merge --auto --squash "$PR_NUMBER"'
    assert_includes queue_workflow, 'GH_REPO: ${{ github.repository }}'
    assert_not_includes queue_workflow, 'workflow_run:'
    assert_not_includes queue_workflow, 'pull-request:'
    refute_path_exists WORKFLOWS.join('dependabot-auto-merge.yml')
  end

  test 'base refresh restores only an existing auto-merge request' do
    update_workflow = File.read(WORKFLOWS.join('auto-update-prs.yml'))

    assert_includes update_workflow, '.mergeStateStatus == "BEHIND"'
    assert_includes update_workflow, '.autoMergeRequest != null'
    assert_includes update_workflow, 'if [[ "$RESTORE_AUTO_MERGE" == "true" ]]'
    assert_includes update_workflow, 'gh pr merge --auto --squash "$PR"'
    assert_not_includes update_workflow, "github.actor != 'dependabot[bot]'"
    assert_not_includes update_workflow, 'Update-branch API failed'
    assert_not_includes update_workflow, 'Failed to trigger workflow'
  end

  test 'stale refresh recreates PRs without changing merge policy' do
    refresh_workflow = File.read(WORKFLOWS.join('dependabot-refresh.yml'))

    assert_includes refresh_workflow, '@dependabot recreate'
    assert_not_includes refresh_workflow, 'gh pr merge'
    assert_not_includes refresh_workflow, '|| true'
  end
end
