#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

require 'open-uri/cached'

class RemoveReferences < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup.reference').remove
    end.to_s
  end
end

class MinistersList < Scraped::HTML
  decorator RemoveReferences
  decorator WikidataIdsDecorator::Links

  field :premiers do
    member_entries.map { |ul| fragment(ul => Officeholder).to_h }
  end

  private

  def member_entries
    table.flat_map { |table| table.xpath('.//tr[th and td]') }
  end

  def table
    noko.xpath('//table[.//th[contains(.,"Premier")]]')
  end
end

class Officeholder < Scraped::HTML
  field :provinceLabel do
    noko.css('th').first.text.tidy
  end

  field :person do
    name_link.attr('wikidata')
  end

  field :personLabel do
    name_link.text.tidy
  end

  private

  def tds
    noko.css('td')
  end

  def name_link
    tds[0].xpath('.//a[@href]').first
  end

  def province_link
    noko.xpath('.//th[1]//a[@href]')
  end
end

url = 'https://en.wikipedia.org/wiki/Template:Current_provincial_governments_in_Canada'
data = MinistersList.new(response: Scraped::Request.new(url: url).response).premiers

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
