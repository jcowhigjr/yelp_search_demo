# 🛡️ lefthook Corruption Prevention Guide

This memory entry outlines best practices and mandatory steps to prevent configuration corruption within the `lefthook.yml` file. Maintaining the integrity of the hooks is critical for reliable CI/CD pipelines.

## 🚨 What is Corruption?
Corruption generally refers to the accidental removal, misplacement, or invalidation of key properties (like `pre-command`, `post-command`, or specific `mise` environment fixes) which leads to hooks failing silently or executing incorrectly.

## ✅ Prevention Workflow
Always follow these steps when modifying `lefthook.yml`:

1. **Backup:** Always commit the current working `lefthook.yml` file with a descriptive message *before* making changes.
2. **Targeted Edits:** Only modify the specific hook or section required. Never perform large-scale, sweeping edits.
3. **Validate Syntax:** Run `lefthook lint` immediately after making changes to ensure the YAML structure is valid.
4. **Test Execution:** Run `lefthook test` to confirm that all existing hooks (especially those related to `mise` environment setup) execute correctly with the new configuration.
5. **Review:** Submit a Pull Request detailing *why* the change is needed and *what* specific hook is affected.

## 🚫 Properties to Avoid (Known Invalid/Deprecated)
Never include the following properties, as they are invalid or deprecated in modern lefthook versions:
- `shell`
- `verbose`
- `skip_output`
- `pre-command` (Use `pre-hook` or structured hooks instead)
- `post-command` (Use `post-hook` or structured hooks instead)
- `fixer`
- Any `workflow-*` commands (Use dedicated CI/CD system configuration)
- `skip: true` (Null skips are deprecated)