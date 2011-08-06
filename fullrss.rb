#!/usr/bin/env ruby
#encoding: UTF-8

# Only tested with UTF-8 encoding XML and HTML
# If there's problems with other encoding, convert to UTF-8 first

require 'rubygems'
require 'hpricot'
require 'open-uri'

def make_para(ppa)
  # &nbsp; is converted to special white space by hpricot, need special care
  pa = ppa.gsub("\302\240", ' ').strip
  (pa == nil) or pa.empty? ? '' : "<p> #{ppa} </p>"
end

def add_xmlns_content(doc)
  rss = doc.at(:rss)
  unless rss.has_attribute? "xmlns:content"
    rss.set_attribute "xmlns:content", "http://purl.org/rss/1.0/modules/content/"
  end
end

def convert_rss(source, content_fetcher)
  feed = open(source) { |f| Hpricot.XML(f) }
  add_xmlns_content(feed)

  item = feed/:item
  item.each do |it|
    content_fetcher.call(it)
  end
  feed
end

def fetch_sina_article(item)
  link = item.at(:link).inner_html
  doc = open(link) { |f| Hpricot(f) }

  article = doc.search("//div[@id = 'articlebody']")
  paras = article/('.articalContent p')
  # use inner_text to conver html entities to character
  content = paras.collect { |pa| make_para(pa.inner_text) }.join("\n")
  item.at(:description).after <<-CDATA
  \n<content:encoded><![CDATA[#{content}]]></content:encoded>
  CDATA
end

sources = [
  # Han Han's blog on Sina, I created this to read his great articles
  ["http://blog.sina.com.cn/rss/1191258123.xml", "hanhan.xml", method(:fetch_sina_article)],
  #["http://solidot.org/index.rss", "solidot.xml", method(:fetch_solidot_article)],
  #["./feed-hanhan.xml", "hanhan.xml", method(:fetch_sina_article)],
]

#print fetch_sina_article('./article.html')

sources.each do |url, file, fetcher|
  full = convert_rss(url, fetcher)
  File.open(file, "w") { |f| f.write(full) }
end

