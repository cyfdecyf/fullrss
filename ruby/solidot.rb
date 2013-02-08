#!/usr/bin/env ruby

require 'fullrss'

source = "http://solidot.org.feedsportal.com/c/33236/f/556826/index.rss"

# remove email and bookmark link
FullRSS.convert_to_cgi_output(source) do |item|
  description = item.at(:description)
  html = description.inner_html
  id = html.index("&lt;img width='1' height='1' src='http://solidot.org.feedsportal.com/c/33236")
  description.inner_html = html[0, id] if id
end
