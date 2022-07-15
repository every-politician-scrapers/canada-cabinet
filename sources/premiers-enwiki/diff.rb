#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/comparison'
require 'every_politician_scraper/scraper_data'
require 'pry'

# Only compare IDs, not names, as those differ between WP/WD
class Comparison < EveryPoliticianScraper::DecoratedComparison
  def columns
    super
    # super.reject { |name| name.to_s == 'personLabel' }
  end
end

diff = Comparison.new('wikidata.csv', 'scraped.csv').diff
puts diff.sort_by { |r| [r.first.to_s, r[1].to_s] }.reverse.map(&:to_csv)
