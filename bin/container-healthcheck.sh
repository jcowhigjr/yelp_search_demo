#!/usr/bin/env bash
mise list | grep -q 'node@20.11.1' && \
mise exec node --version | grep -q 'v20.11.1'
