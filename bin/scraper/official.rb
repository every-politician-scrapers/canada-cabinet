#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    REMAP = {
      'Deputy Prime Minister and Minister of Finance'                                               => ['Deputy Prime Minister', 'Minister of Finance'],
      'Minister and Special Representative for the Prairies'                                        => ['Minister without Portfolio', 'Special Representative for the Prairies'],
      'Minister for Women and Gender Equality and Rural Economic Development'                       => ['Minister for Women and Gender Equality', 'Minister for Rural Economic Development'],
      'Minister of Economic Development and Official Languages'                                     => ['Minister of Economic Development', 'Minister of Official Languages'],
      'Minister of Middle Class Prosperity and Associate Minister of Finance'                       => ['Minister of Middle Class Prosperity', 'Associate Minister of Finance'],
      'Minister of Veterans Affairs and Associate Minister of National Defence'                     => ['Minister of Veterans Affairs', 'Associate Minister of National Defence'],
      'President of the Queen’s Privy Council for Canada and Minister of Intergovernmental Affairs' => ['President of the Queen’s Privy Council for Canada', 'Minister of Intergovernmental Affairs'],
    }.freeze

    field :name do
      noko.css('.name').text.tidy
          .delete_prefix('The Right Honourable ')
          .delete_prefix('The Honourable ')
    end

    field :position do
      REMAP.fetch(raw_position, raw_position)
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

file = Pathname.new 'html/official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
