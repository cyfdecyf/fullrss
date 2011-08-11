#!/usr/bin/env ruby

require 'fullrss'

source = "http://feeds.macrumors.com/MacRumors-All"

FullRSS.convert_to_cgi_output(source) do |item|
  description = item.at(:description)
  html = description.inner_html
  buf = ''
  html.each_line do |line|
    break if line =~ %r{&lt;p&gt;&lt;a href="http://feedads.g.doubleclick.net/}
    buf << line
  end
  description.inner_html = buf
end
