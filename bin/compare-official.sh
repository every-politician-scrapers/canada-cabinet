#!/bin/bash

bundle exec ruby bin/scraper/official.rb | ifne tee data/official.csv
bundle exec ruby bin/scraper/wikidata.rb meta.json | sed -e 's/T00:00:00Z//g' | qsv dedup -s psid | ifne tee data/wikidata.csv
bundle exec ruby bin/diff.rb | tee data/diff.csv
