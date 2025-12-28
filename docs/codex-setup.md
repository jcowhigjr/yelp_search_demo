# Codex Environment Setup

Codex workers should mirror the CI bootstrap steps from `.github/workflows/main.yml` before running project commands. The shared configuration lives in `.project/config/codex.yml` and should be executed in order:

1. **Clear mise cache and config:** remove `~/.local/share/mise` and `~/.config/mise`.
2. **Run setup-environment:** set `SETUP_SKIP_NODE=true` and execute `bash bin/setup-environment.sh`.
3. **Ensure mise is on PATH:** export `$HOME/.local/bin` into `PATH` so subsequent `mise`-provided shims are available.

Follow this sequence at session start to keep Codex runs consistent with CI.
