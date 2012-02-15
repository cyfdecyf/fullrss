#!/usr/bin/env ruby

require 'fullrss'

source = "http://feeds.feedburner.com/osxdaily"

FullRSS.convert_to_cgi_output(source) do |item|
  content = item.at("content:encoded")
  html = content.inner_html
  buf = ''
  html.each_line do |line|
    break if line =~ %r{a href="http://feedads.g.doubleclick.net/}
    buf << line
  end
  content.inner_html = buf + ']]>'
end
