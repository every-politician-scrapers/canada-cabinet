#!/bin/bash

cd $(dirname $0)

bundle exec ruby scraper.rb $(jq -r .source meta.json) | ifne tee scraped.csv
wd sparql -f csv wikidata.js | sed -e 's/T00:00:00Z//g' -e 's#http://www.wikidata.org/entity/##g' | qsv dedup -s psid | ifne tee wikidata.csv
bundle exec ruby diff.rb | qsv sort -s startdate | qsv select 1,3,2,4,5 | tee diff.csv

cd ~-
