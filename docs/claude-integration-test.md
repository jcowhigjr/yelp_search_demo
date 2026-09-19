# Claude Code Review Integration Test

This file tests the production Claude Code review workflow.

## What to Test

1. **Workflow triggers**: PR creation should trigger the workflow
2. **Agent mode**: Workflow should wait for `@claude` trigger
3. **Authentication**: Should use OIDC + ANTHROPIC_API_KEY
4. **Review quality**: Claude should provide meaningful feedback

## Expected Behavior

- Workflow runs on PR open/sync/reopen, but only *reviews* when triggered
- Agent mode: only responds when triggered
- Comment `@claude` to get an AI review, or put `@claude` in the PR body or title
- Adding a `claude-review` label does **not** trigger a review: the action's
  label trigger only fires for `issues` events, never PR labels

## Sample Code for Review

Here's some Ruby code with potential issues:

```ruby
def calculate_total(items)
  total = 0
  items.each do |item|
    total = total + item[:price]
  end
  return total
end
```

Could be improved with:
- Using `sum` method
- Better variable naming
- Input validation
