#!/usr/bin/env bash
set -e

ROOT="${BASH_SOURCE%/*}"/..

export PROJECT_ROOT="$ROOT"
eval "export $(cat "$ROOT"/deploy.conf | grep -v '^#' | grep -v '^\s*$' | tr '\n' ' ')"
