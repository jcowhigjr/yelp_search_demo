# Claude Workflow Troubleshooting Notes

## Observed Failure
- GitHub Action run logs show `API Error: 401 {"type":"error","error":{"type":"authentication_error","message":"Invalid bearer token"}}`.
- The active workflow configuration (`.github/workflows/claude.yml`) only passed the `claude_code_oauth_token` input, so the action attempted to authenticate with the value stored in the `CLAUDE_CODE_OAUTH_TOKEN` secret.

## Why This Is Not an External Permission Problem
- A `401 Invalid bearer token` response from the Anthropic API indicates that the token presented with the request is not valid for authentication. This happens when the secret is empty, mistyped, or contains the wrong credential type—not because of repository permissions.
- The Claude Code action explicitly accepts either an Anthropic API key (`anthropic_api_key`) *or* a Claude OAuth token (`claude_code_oauth_token`) for authentication. Providing a valid value for one of those inputs is sufficient to run the workflow successfully.

## Remediation Steps Within Repository Control
1. Ensure a valid Anthropic credential is stored in the repository secrets:
   - `ANTHROPIC_API_KEY` for direct API access (value should begin with `sk-ant-`).
   - `CLAUDE_CODE_OAUTH_TOKEN` if using the Claude desktop app to generate an OAuth token.
2. The workflow now validates that at least one of these secrets is present and will fail fast with a clear error if neither is configured.
3. When both secrets are present the job prefers the API key; otherwise it falls back to the OAuth token before invoking the Claude action.
4. Re-run the workflow to confirm that authentication succeeds once the correct secret is supplied.

The workflow only fails when no valid credential is provided. Once a correct API key or OAuth token is configured, the action can authenticate without requiring any permissions beyond those already granted in the workflow file.
