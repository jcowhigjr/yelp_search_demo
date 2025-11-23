# @claude-suggest Manual User Steps

This document outlines the manual steps users must take after triggering the @claude-suggest workflow to complete the code review and deployment process.

## Overview

The @claude-suggest feature creates GitHub suggestion comments that appear as actionable buttons on your PR. However, there are required manual steps to complete the process.

## Required Manual Steps

### 1. Review and Apply Suggestions

When @claude-suggest runs, it creates individual suggestion comments on specific lines of code. For each suggestion:

**Option A: Accept Suggestion**
- Click the **"Apply suggestion"** button on suggestions you agree with
- This commits the change directly to your branch
- GitHub will show "✅ Applied" on accepted suggestions

**Option B: Reject Suggestion**
- If you disagree with a suggestion, simply leave it unapplied
- You can optionally add a comment explaining why you rejected it

### 2. Resolve All Suggestion Conversations

After reviewing all suggestions (whether applied or rejected):

- **Important**: Click **"Resolve conversation"** on each suggestion comment thread
- This is required by branch protection rules for the PR to be mergeable
- GitHub will show the PR as blocked until all conversations are resolved

### 3. Merge the Pull Request

Once all suggestion conversations are resolved:

- Click **"Squash and merge"** (or your preferred merge strategy)
- Ensure all CI checks are passing
- Complete the merge to deploy your changes

### 4. Verify Deployment (Recommended)

After merging:

- Click on the **deployment status** in the PR or check the Actions tab
- Perform a **manual smoke test** of the deployed changes
- Verify the applied suggestions work as expected in the live environment

## Example Workflow

```
1. Comment "@claude-suggest" on your PR
   ↓
2. Wait for Claude to analyze and post suggestions (~2-3 minutes)
   ↓
3. Review each suggestion:
   - Click "Apply suggestion" for good ones ✅
   - Leave others unapplied if you disagree ❌
   ↓
4. Click "Resolve conversation" on ALL suggestion threads
   ↓
5. Click "Squash and merge" when ready
   ↓
6. Check deployment status and smoke test
```

## Important Notes

- **All conversations must be resolved** for merge to be allowed
- **Applied suggestions create commits** automatically
- **You can apply multiple suggestions in batch** if desired
- **Rejected suggestions require no action** except resolving the conversation
- **CI must pass** regardless of suggestion status

## Troubleshooting

**"PR cannot be merged"**: Ensure all suggestion conversations are marked as resolved

**"Merge blocked"**: Check that all required status checks are passing

**"Changes requested"**: Look for any unresolved suggestion comment threads

---

This process ensures code quality while giving developers full control over which AI suggestions to accept or reject.