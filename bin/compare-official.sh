#!/bin/bash

bundle exec ruby bin/scraper/official.rb > data/official.csv
bundle exec ruby bin/scraper/wikidata.rb meta.json | sed -e 's/T00:00:00Z//g' | qsv dedup -s psid > data/wikidata.csv
bundle exec ruby bin/diff.rb | tee data/diff.csv
