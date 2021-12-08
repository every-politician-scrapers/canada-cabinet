#!/bin/sh

IFS=$'\n'

mkdir -p enwiki

for page in $(fgrep -v Q9682 html/current.csv | qsv select enwiki | qsv search . | qsv dedup | qsv sort | qsv behead); do
  echo $page
  json=$(printf '"%s"' "$page" | xargs wtf_wikipedia)
  pageid=$(printf '%s' "$json" | jq -r .pageID)
  printf '%s' "$json" | jq -r '.sections |= [.[0]]' > enwiki/$pageid
done
