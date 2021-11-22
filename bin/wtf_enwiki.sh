#!/bin/sh

IFS=$'\n'

mkdir -p enwiki

for page in $(qsv select enwiki html/current.csv | qsv search . | qsv behead); do
  echo $page
  json=$(wtf_wikipedia $page)
  pageid=$(printf '%s' "$json" | jq -r .pageID)
  printf '%s' "$json" | jq -r . > enwiki/$pageid
done
