#!/bin/bash

bundle exec ruby bin/scraper/premiers-wikipedia.rb > data/premiers-wikipedia.csv
# WD list fetched separately TODO: move together
bundle exec ruby bin/diff-premiers.rb > data/diff-premiers.csv
