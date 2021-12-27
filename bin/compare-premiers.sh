#!/bin/bash

bundle exec ruby bin/scraper/premiers-wikipedia.rb | ifne tee data/premiers-wikipedia.csv
# WD list fetched separately TODO: move together
bundle exec ruby bin/diff-premiers.rb | ifne tee data/diff-premiers.csv
