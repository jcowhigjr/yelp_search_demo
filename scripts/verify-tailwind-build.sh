#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

BUILD_PATH="app/assets/builds/tailwind.css"
TOKENS=(".bg-base" ".text-base" "--color-bg")
MEDIA_TOKEN_REGEX='@media \(prefers-color-scheme: ?dark\)'

echo "🌬️  Building Tailwind assets (production mode)"
MISE_ENV=${MISE_ENV:-}
if command -v mise >/dev/null 2>&1; then
  mise exec -- bin/rails tailwindcss:build
else
  bin/rails tailwindcss:build
fi

if [[ ! -f "$BUILD_PATH" ]]; then
  echo "❌ Tailwind build missing: $BUILD_PATH was not generated"
  exit 1
fi

echo "🔍 Validating required dark-mode tokens in $BUILD_PATH"
missing_tokens=0
css_contents=$(<"$BUILD_PATH")
for token in "${TOKENS[@]}"; do
  # Use `--` to ensure tokens like `--color-bg` are treated as patterns, not options
  if ! grep -q -- "$token" <<<"$css_contents"; then
    echo "❌ Missing token: $token"
    missing_tokens=1
  fi
done

if ! grep -Eq "$MEDIA_TOKEN_REGEX" <<<"$css_contents"; then
  echo "❌ Missing token: @media (prefers-color-scheme: dark)"
  missing_tokens=1
fi

if [[ "$missing_tokens" -ne 0 ]]; then
  cat <<'EOF'
⚠️  The production CSS is missing dark-mode utilities.
    Run 'bin/dev' locally to confirm styling, then re-run this script
    to regenerate Tailwind outputs before committing.
EOF
  exit 1
fi

echo "✅ Tailwind build contains required dark-mode utilities"
