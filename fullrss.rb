#encoding: UTF-8

# Only tested with UTF-8 encoding XML and HTML
# If there's problems with other encoding, convert to UTF-8 first

require 'rubygems'
Gem.path.unshift "/home1/bugeiqia/.gem/ruby/1.8"

require 'fileutils'
require 'hpricot'
require 'open-uri'

module FullRSS
  CGI_HEADER = "Content-Type: application/rss+xml\r\n\r\n"
  CACHE_DIR = File.join(File.expand_path(File.dirname(__FILE__)), 'content')

  def self.create_para(ppa)
    # &nbsp; is converted to special white space by hpricot, need special care
    pa = ppa.gsub("\302\240", ' ').strip
    (pa == nil) or pa.empty? ? '' : "<p> #{ppa} </p>"
  end

  def self.create_cdata(content)
    "<![CDATA[#{content}]]>"
  end

  def self.create_content(content)
    "\n<content:encoded>#{create_cdata(content)}</content:encoded>"
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
      content = get_content(it)
      if content
        @fetcher.call(it, content)
      else
        content = @fetcher.call(it)
        store_content(it, content)
      end
    end

    def item2path(item)
      link = item.at(:link).inner_html
      File.join(CACHE_DIR, link.sub('http://', ''))
    end

    def get_content(it)
      path = item2path it

      if File.exists? path
        IO.read path
      else
        return nil
      end
    end

    def store_content(it, content)
      path = item2path it
      dir = File.dirname(path)

      FileUtils.mkdir_p dir
      File.open(path, "w") do |f|
        f.write content
      end
    end

    def cgi_output
      # Get the feed first and then send it with the content together to avoid
      # GReader complaining feed not found
      feed = convert_rss
      print CGI_HEADER
      print feed
    end

    def add_xmlns_content(doc)
      rss = doc.at(:rss)
      unless rss.has_attribute? "xmlns:content"
        rss.set_attribute "xmlns:content", "http://purl.org/rss/1.0/modules/content/"
      end
    end
  end

end
