#!/bin/bash

cd $(dirname $0)

bundle exec ruby scraper.rb > scraped.csv
bundle exec ruby wikidata.rb meta.json | sed -e 's/T00:00:00Z//g' | qsv dedup -s psid > wikidata.csv
bundle exec ruby diff.rb | tee diff.csv

cd ~-
