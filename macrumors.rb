#!/usr/bin/env ruby

require 'fullrss'

def convert_macrumors_article(item)
  description = item.at(:description)
  html = description.inner_html
  buf = ''
  html.each_line do |line|
    break if line =~ %r{&lt;p&gt;&lt;a href="http://feedads.g.doubleclick.net/}
    buf << line
  end
  description.inner_html = buf
end

source = "http://feeds.macrumors.com/MacRumors-All"

FullRSS::RSS.new(source, method(:convert_macrumors_article)).cgi_output

