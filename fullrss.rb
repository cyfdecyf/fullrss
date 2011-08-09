#encoding: UTF-8

# Only tested with UTF-8 encoding XML and HTML
# If there's problems with other encoding, convert to UTF-8 first

require 'rubygems'
Gem.path.unshift "/home1/bugeiqia/.gem/ruby/1.8"

require 'hpricot'
require 'open-uri'

module FullRSS
  CGI_HEADER = "Content-Type: application/rss+xml\r\n\r\n"

  def self.make_para(ppa)
    # &nbsp; is converted to special white space by hpricot, need special care
    pa = ppa.gsub("\302\240", ' ').strip
    (pa == nil) or pa.empty? ? '' : "<p> #{ppa} </p>"
  end

  def self.create_content(content)
    return "\n<content:encoded><![CDATA[#{content}]]></content:encoded>"
  end

  class RSS
    def initialize(source, fetcher, cache = false)
      @source = source
      @fetcher = fetcher
      @cache = cache
    end

    def convert_rss
      feed = open(@source) { |f| Hpricot.XML(f) }
      add_xmlns_content(feed)

      item = feed/:item
      item.each do |it|
        if @cache == false
          @fetcher.call(it)
        else
          upsert_content(it)
        end
      end
      feed
    end

    def upsert_content(it)
      content = find_content(it)
      if content
        @fetcher.call(it, content)
      else
        content = @fetcher.call(it)
        insert_cache_content(it, content)
      end
    end

    def find_content(it)
      return nil
    end

    def insert_content(it, content)
    end

    def cgi_output
      print CGI_HEADER
      print convert_rss
    end

    def add_xmlns_content(doc)
      rss = doc.at(:rss)
      unless rss.has_attribute? "xmlns:content"
        rss.set_attribute "xmlns:content", "http://purl.org/rss/1.0/modules/content/"
      end
    end
  end

end
