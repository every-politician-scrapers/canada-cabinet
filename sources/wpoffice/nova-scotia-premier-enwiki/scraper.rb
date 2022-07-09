#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

require 'open-uri/cached'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Mandates'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[image no name dates].freeze
    end

    def raw_combo_dates
      combo_date_cell.children.map(&:text).map(&:tidy).reject(&:empty?)
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
