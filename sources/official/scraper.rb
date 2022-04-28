#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    REMAP = {
      'Minister and Special Representative for the Prairies'                   => ['Minister without Portfolio', 'Special Representative for the Prairies'],
      'Minister for Women and Gender Equality and Rural Economic Development'  => ['Minister for Women and Gender Equality', 'Minister for Rural Economic Development'],
      'Minister of Economic Development and Official Languages'                => ['Minister of Economic Development', 'Minister of Official Languages'],
      'Minister of Canadian Heritage and Quebec Lieutenant'                    => ['Minister of Canadian Heritage', 'Quebec Lieutenant']
    }.freeze

    field :name do
      noko.css('.name').text.tidy
          .delete_prefix('The Right Honourable ')
          .delete_prefix('The Honourable ')
    end

    field :position do
      raw_position.split(/ and (?=Minister)/)
        .flat_map { |posn| posn.split(/, (?=Minister)/) }
        .flat_map { |posn| posn.split(/ and (?=Associate Minister)/) }
        .map(&:tidy).map do |posn|
        REMAP.fetch(posn, posn)
      end
    end

    private

    def raw_position
      noko.css('.role').text.tidy
    end
  end

  class Members
    def member_container
      noko.css('li.minister-row')
    end
  end
end

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
