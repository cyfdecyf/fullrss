#!/usr/bin/env ruby

require 'fullrss'

def convert_macrumors_article(item)
  content = item.at("content:encoded")
  html = content.inner_html
  buf = ''
  html.each_line do |line|
    break if line =~ %r{a href="http://feedads.g.doubleclick.net/}
    buf << line
  end
  content.inner_html = buf + ']]>'
end

source = "http://feeds.feedburner.com/osxdaily"
source = "./osxdaily"

FullRSS::RSS.new(source, method(:convert_macrumors_article)).cgi_output

