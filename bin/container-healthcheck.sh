#!/usr/bin/env bash
# Core runtime verification
mise exec -- ruby --version | grep -qF "3.4.1"
