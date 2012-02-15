#!/usr/bin/env ruby

require 'fullrss'

source = "http://blog.sina.com.cn/rss/1191258123.xml"

FullRSS.convert_to_cgi_output(source, true) do |item, content|
  if content == nil
    link = item.at(:link).inner_html
    doc = open(link) { |f| Hpricot(f) }

    article = doc.search("//div[@id = 'articlebody']")
    paras = article/('.articalContent p')
    # use inner_text to conver html entities to character
    content = paras.collect { |pa| FullRSS.create_para(pa.inner_text) }.join("\n")
  end
  item.at(:description).inner_html = FullRSS.create_cdata(content)
  content
end
