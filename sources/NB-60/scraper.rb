#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Notes'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[_ name party riding start].freeze
    end

    field :party do
      tds[2].css('a/@wikidata').text
    end

    field :partyLabel do
      tds[2].css('a').text
    end

    field :riding do
      tds[3].css('a/@wikidata').text
    end

    field :ridingLabel do
      tds[3].css('a').text
    end

    def startDate
    end

    def endDate
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
