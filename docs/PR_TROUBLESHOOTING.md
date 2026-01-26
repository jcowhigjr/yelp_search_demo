# PR Troubleshooting Guide

## Common Issues & Solutions

### 1. PR Blocked by Pending Checks
- **Cause**: Required status checks haven't completed
- **Solution**:
  1. Check GitHub Actions for failed jobs
  2. Verify all required checks in branch protection rules
  3. Ensure jobs have proper event triggers (`pull_request` vs `push`)

### 2. "Event payload missing 'pull_request' key"
- **Cause**: Job requires PR context but triggered by push
- **Solution**:
  1. Add `if: github.event_name == 'pull_request'` to job
  2. Handle non-PR events gracefully in scripts

### 3. Inconsistent Ruby Versions
- **Cause**: Mismatched Ruby versions in project files
- **Solution**: Run `bin/validate_ruby_versions` locally

## Required Status Checks
- CodeQL Analysis
- Rails Tests
- Risk Assessment
- Test-Next

[View CI Dashboard](https://github.com/jcowhigjr/yelp_search_demo/actions)
