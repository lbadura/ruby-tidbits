# A simple web scraper to get the recent currency data from NBP
#
require 'rubygems'
require 'mechanize'

class NBPScraper
  # url to NBP's ratings of A class currencies
  URL = 'http://www.nbp.pl/home.aspx?f=/kursy/kursya.html'  

  def initialize(currency_code = 'EUR')
    @currency_code = currency_code
    @url = NBPScraper::URL
    @page = Mechanize.new().get(@url)
  end

  def price
    regexp = Regexp.new(@currency_code)
    @page.search('//tr[@valign="middle"]').each do |tr|
      content = tr.search('td').each do |td|
        if (regexp.match(td.content))
          return td.next_element.content.sub(',','.').to_f
        end
      end
    end
  end
end

# usage
# puts NBPScraper.new('EUR').price
