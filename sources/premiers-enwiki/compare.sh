#!/bin/bash

cd $(dirname $0)

bundle exec ruby scraper.rb > scraped.csv
wd sparql -f csv wikidata.js | sed -e 's/T00:00:00Z//g' -e 's#http://www.wikidata.org/entity/##g' > wikidata.csv
bundle exec ruby diff.rb | tee diff.csv

cd ~-
