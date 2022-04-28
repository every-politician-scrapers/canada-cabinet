#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/comparison'

diff = EveryPoliticianScraper::NulllessComparison.new('wikidata.csv', 'scraped.csv').diff
puts diff.sort_by { |r| [r.first, r[1].to_s] }.reverse.map(&:to_csv)
