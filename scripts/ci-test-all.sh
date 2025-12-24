#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -gt 0 ]; then
  cmd=(bin/rails test "$@")
else
  cmd=(bin/rails test:all)
fi

CI=true RAILS_ENV=test HEADLESS=true CUPRITE=true APP_HOST=localhost \
  mise exec -- "${cmd[@]}"
