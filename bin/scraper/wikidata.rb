#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/wikidata_query'

config_file = ARGV.first or abort "Usage: #{$PROGRAM_NAME} <config_file>"
puts EveryPoliticianScraper::WikidataCabinet.new(config_file).csv
