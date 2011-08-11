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

  def self.convert_to_cgi_output(source, cache = false, &converter)
    rss = FullRSS::RSS.new(source, cache)
    rss.each_item! &converter
    rss.cgi_output
  end

  class RSS
    def initialize(source, cache = false)
      @source = source
      @cache = cache
    end

    # To use cache, the converter should return the content it wants to be cached
    def each_item!(&converter)
      @converter = converter
      @feed = open(@source) { |f| Hpricot.XML(f) }
      add_xmlns_content(@feed)

      item = @feed/:item
      item.each do |it|
        if @cache == false
          @converter.call(it)
        else
          upsert_content(it)
        end
      end
      self
    end

    def cgi_output
      print CGI_HEADER
      print @feed
    end

    private

    def upsert_content(it)
      content = get_content(it)
      if content
        @converter.call(it, content)
      else
        content = @converter.call(it)
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

    def add_xmlns_content(doc)
      rss = doc.at(:rss)
      unless rss.has_attribute? "xmlns:content"
        rss.set_attribute "xmlns:content", "http://purl.org/rss/1.0/modules/content/"
      end
    end
  end

end
