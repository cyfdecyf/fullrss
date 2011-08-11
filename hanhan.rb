#!/usr/bin/env ruby

require 'fullrss'

def fetch_sina_article(item, content = nil)
  if content == nil
    link = item.at(:link).inner_html
    doc = open(link) { |f| Hpricot(f) }

    article = doc.search("//div[@id = 'articlebody']")
    paras = article/('.articalContent p')
    # use inner_text to conver html entities to character
    content = paras.collect { |pa| FullRSS.create_para(pa.inner_text) }.join("\n")
  end
  item.at(:description).after FullRSS.create_content(content)
  content
end

source = "http://blog.sina.com.cn/rss/1191258123.xml"

FullRSS::RSS.new(source, method(:fetch_sina_article), true).cgi_output
