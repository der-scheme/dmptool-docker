#!/usr/bin/env bash
set -e

source "${BASH_SOURCE%/*}"/.loadconfig.sh

for infile in $(find . -type f -name '*.tpl')
do
  outfile="${infile%.*}"
  envsubst > "$outfile" < "$infile"
done
