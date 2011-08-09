#!/usr/bin/env ruby

require 'fullrss'

# remove email and bookmark link
def convert_solidot_article(item)
  description = item.at(:description)
  html = description.inner_html
  id = html.index("&lt;img width='1' height='1' src='http://solidot.org.feedsportal.com/c/33236")
  description.inner_html = html[0, id] if id
end

source = "http://solidot.org.feedsportal.com/c/33236/f/556826/index.rss"

FullRSS::RSS.new(source, method(:convert_solidot_article)).cgi_output

