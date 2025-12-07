## Fix system test environment variable configuration

### Problem

System tests require manual environment variable setup and don't work consistently across local development and CI. Developers must manually set:

```bash
HEADLESS=true CUPRITE=true APP_HOST=localhost mise exec -- bin/rails test:system
```

### Current State

- Environment variables are set in `test/test_helper.rb` but with inconsistent syntax
- Tests fail when environment variables aren't manually set
- CI and local development have different behaviors
- PR #1171 attempted to fix this but introduced test failures

### Acceptance Criteria

1. **System tests work without manual environment setup**
   - `mise exec -- bin/rails test:system` works out of the box
   - `mise run test-system` works with mise tasks
   - Individual test files run without environment setup

2. **Consistent behavior across environments**
   - Local development matches CI behavior
   - Headless mode works by default
   - Debug mode available when explicitly requested

3. **No test regressions**
   - All existing system tests continue to pass
   - No new test failures introduced
   - Performance remains acceptable

### Technical Requirements

- Set default environment variables in test helper
- Use proper Ruby environment variable syntax
- Ensure defaults don't override explicit environment settings
- Maintain backward compatibility with existing workflows

### Files to Modify

- `test/test_helper.rb` - Fix environment variable defaults
- Verify `test/application_system_test_case.rb` configuration works
- Test with existing system test suite

### Definition of Done

- [ ] System tests run without manual environment setup
- [ ] All existing tests pass
- [ ] CI continues to work correctly
- [ ] Local development works consistently
- [ ] Documentation updated if needed

### Risk Level: LOW
- Minimal configuration change
- Well-understood environment variable handling
- Easy to verify and rollback

### Estimated Effort: 1-2 hours
- Fix environment variable syntax: 30 minutes
- Test validation: 30-60 minutes
- Documentation updates: 30 minutes

### Success Metrics

- New developers can run system tests without setup instructions
- CI and local behavior are identical
- No more "forgot to set environment variables" errors
