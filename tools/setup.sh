#!/usr/bin/env bash
set -e

source "${BASH_SOURCE%/*}"/.loadconfig.sh

docker-compose run --rm dmptool setup "$@" "$HOSTNAME"
