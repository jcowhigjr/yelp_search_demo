---
name: Project Issue Template
about: Standard template for reporting issues and requesting improvements
title: '[COMPONENT] Brief description of the issue'
labels: ['needs-triage']
assignees: ''
---

## Summary

<!-- Provide a clear and concise summary of the issue or improvement request -->
**Issue Type:** [Bug Report | Feature Request | Enhancement | Documentation | Security | Performance]

**Brief Description:**
<!-- One-sentence summary of what needs to be addressed -->

**Impact Level:** [Critical | High | Medium | Low]

---

## Background

### Current State
<!-- Describe the current behavior or state of the system -->

### Expected Behavior
<!-- Describe what should happen instead -->

### Steps to Reproduce (if applicable)
1. <!-- First step -->
2. <!-- Second step -->
3. <!-- Third step -->
4. <!-- Observed result -->

### Environment Information
- **Branch:** <!-- Current branch or version -->
- **Environment:** [Development | Staging | Production | Local]
- **Browser/Platform:** <!-- If applicable -->
- **Related Components:** <!-- List affected components, controllers, models, etc. -->

### Context & Motivation
<!-- Why is this issue important? What problem does it solve? -->

---

## Suggested Improvements

### Proposed Solution
<!-- Detailed description of the proposed changes -->

### Technical Approach
<!-- High-level technical implementation details -->

### Alternative Solutions Considered
<!-- Other approaches that were considered but not chosen -->

### Implementation Checklist
- [ ] Code changes implemented
- [ ] Tests written/updated (see `/docs/pr-workflow.md` for testing standards)
- [ ] Documentation updated (follow `/docs` conventions)
- [ ] Security review completed (if applicable)
- [ ] Performance impact assessed
- [ ] Accessibility considerations addressed (if UI changes)

### Quality Assurance Requirements
<!-- Reference lefthook.yml CI/CD standards -->
- [ ] Pre-commit hooks pass (`lefthook run workflow-status`)
- [ ] Code style checks pass (rubocop, erb_lint, prettier)
- [ ] Security audits pass (brakeman, gem audit, js audit)
- [ ] All tests pass (Rails tests, system tests, frontend tests)
- [ ] Environment validation passes (`bin/container-healthcheck.sh`)
- [ ] Branch protection rules followed (no direct commits to main/develop)

---

## Categorization

### Component Areas
<!-- Check all that apply -->
- [ ] **Backend/Rails** (models, controllers, services)
- [ ] **Frontend/JavaScript** (UI components, interactions)
- [ ] **Database** (migrations, schema changes)
- [ ] **DevOps/Infrastructure** (Docker, CI/CD, deployment)
- [ ] **Security** (authentication, authorization, data protection)
- [ ] **Performance** (optimization, caching, queries)
- [ ] **Documentation** (guides, API docs, README updates)
- [ ] **Testing** (unit tests, system tests, test infrastructure)

### Priority Classification
- [ ] **Blocking** - Prevents other work or causes system failure
- [ ] **High Priority** - Important for next release
- [ ] **Medium Priority** - Should be addressed soon
- [ ] **Low Priority** - Nice to have improvement
- [ ] **Technical Debt** - Code quality or maintainability improvement

### Effort Estimation
- [ ] **Small** (< 4 hours) - Minor fix or small feature
- [ ] **Medium** (1-3 days) - Moderate changes with testing
- [ ] **Large** (1-2 weeks) - Significant feature or refactoring
- [ ] **Epic** (> 2 weeks) - Major initiative requiring planning

---

## Next Steps

### Immediate Actions Required
<!-- What needs to happen first? -->
1. <!-- First action item -->
2. <!-- Second action item -->
3. <!-- Third action item -->

### Dependencies & Blockers
<!-- What must be completed before this can proceed? -->
- [ ] <!-- Dependency 1 -->
- [ ] <!-- Dependency 2 -->
- [ ] <!-- Any blocking issues -->

### Workflow Compliance
<!-- Ensure adherence to project standards -->
- [ ] Follow git workflow documented in `/docs/git-workflow.md`
- [ ] Use lefthook commands for branch management (`lefthook run workflow-new-feature`)
- [ ] Ensure PR follows guidelines in `/docs/pr-workflow.md`
- [ ] Reference appropriate documentation in `/docs/` for context
- [ ] Validate environment setup per `/docs/container-organization.md`

### Review & Validation Criteria
<!-- How will we know this is complete? -->
- [ ] **Functionality**: Feature works as designed
- [ ] **Code Quality**: Passes all lefthook pre-commit and pre-push hooks
- [ ] **Performance**: No degradation in system performance
- [ ] **Security**: No new vulnerabilities introduced
- [ ] **Documentation**: Updated per `/docs` conventions
- [ ] **Testing**: Comprehensive test coverage maintained
- [ ] **Integration**: Works with existing system components

### Assignment & Timeline
- **Assignee:** <!-- Who will work on this? -->
- **Target Milestone:** <!-- Which release/sprint? -->
- **Estimated Completion:** <!-- When should this be done? -->
- **Review Required:** [Code Review | Security Review | Architecture Review | None]

---

## Additional Information

### Supporting Documentation
<!-- Link to relevant project documentation -->
- Reference: `/docs/git-workflow.md` for workflow standards
- Reference: `/docs/pr-workflow.md` for pull request guidelines
- Reference: `/docs/intelligent-ci-cd.md` for CI/CD processes
- Reference: `lefthook.yml` for automated quality checks
- Related Issue: #<!-- Link to related issues -->
- Related PR: #<!-- Link to related pull requests -->

### Notes for Implementation
<!-- Any additional context, warnings, or considerations -->

### Screenshots/Mockups
<!-- If applicable, add visual aids -->

---

**Template Version:** 1.0  
**Last Updated:** {{ date }}  
**Compliance Standards:** Follows `/docs` conventions and `lefthook.yml` CI/CD requirements
