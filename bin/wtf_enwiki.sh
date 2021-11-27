#!/bin/sh

IFS=$'\n'

mkdir -p enwiki

for page in $(qsv select enwiki html/current.csv | qsv search . | qsv dedup | qsv sort | qsv behead); do
  echo $page
  json=$(printf '"%s"' "$page" | xargs wtf_wikipedia)
  pageid=$(printf '%s' "$json" | jq -r .pageID)
  printf '%s' "$json" | jq -r . > enwiki/$pageid
done
