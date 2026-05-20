# Git Security Scrubbing Guide

This document provides a standard operating procedure for removing sensitive information (API keys, credential keys, etc.) from a Git repository's history. 

> [!CAUTION]
> **Git never forgets.** Even if you delete a file in a new commit, it remains in the history. To truly secure a public repository, you must rewrite the history and purge GitHub's internal caches.

## Prerequisites
- Install `git-filter-repo`: `brew install git-filter-repo`
- **Verified Backups**: Ensure you have the physical `*.key` files and `*.yml.enc` files stored in a secure location outside the repository (e.g., a password manager).

---

## Step 1: Identification & Verification
1. **Find the Secrets**: Use `git grep` to find literal secret strings across all commits.
   ```bash
   git grep "YOUR_SECRET_STRING" $(git rev-list --all)
   ```
2. **Verify Decryption**: Ensure your current key works for your credentials.
   ```bash
   RAILS_MASTER_KEY=$(cat config/credentials/production.key) bundle exec rails credentials:show --environment production
   ```

## Step 2: The "Surgical" Scrub
Use `git-filter-repo` to permanently remove files and replace strings.

1. **Create a secret list**: Create a `secrets.txt` file with one secret per line (ensure no trailing newlines/spaces).
2. **Purge Files and Replace Text**:
   ```bash
   # Remove sensitive files from ALL commits
   git filter-repo --force --path .env.development \
                   --path .env.test.local \
                   --path config/credentials/development.key \
                   --path config/credentials/test.key \
                   --path config/credentials/production.key \
                   --invert-paths

   # Replace literal strings with a placeholder
   git filter-repo --force --replace-text secrets.txt
   ```

## Step 3: Synchronizing Branches
Force-update your primary branches to match the clean history.
```bash
# Sync master to the clean develop
git checkout master
git reset --hard develop
```

## Step 4: The GitHub "Clean Slate" (Crucial)
GitHub's internal database caches Pull Request diffs and orphaned commits. **To truly remove secrets from a public repo, you must recreate it.**

1. **Delete the Repo**: Go to **GitHub > Settings > Danger Zone > Delete this repository**.
2. **Recreate the Repo**: Create a new empty repository with the same name.
3. **Push Clean History**:
   ```bash
   git remote remove origin
   git remote add origin https://github.com/USER/REPO.git
   git push -u origin develop
   git push origin master
   ```

## Step 5: Post-Scrub Restoration
1. **Rotate Secrets**: Treat every scrubbed secret as compromised. Generate new keys/passwords as soon as possible.
2. **GitHub Secrets**: Re-add `RAILS_TEST_KEY`, etc., to **Settings > Secrets and variables > Actions**.
3. **Branch Protection**: Import the `github_ruleset_production.json` to restore safety rules.
4. **Cleanup**: Delete the local `secrets.txt` and temporary ruleset files.

---

## How to Prevent Future Leaks
- **Never commit `.env` files**: Ensure they are in `.gitignore` from day one.
- **Use Rails Credentials**: Always store secrets in `config/credentials/*.yml.enc`.
- **Pre-commit Hooks**: Use `Lefthook` or `pre-commit` to scan for secrets before they are ever committed.
