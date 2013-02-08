local http = require "resty.http"
local hc = http:new()

local solidot_url = "http://solidot.org.feedsportal.com/c/33236/f/556826/index.rss"
local ok, code, headers, status, body = hc:request {
  url = solidot_url,
  method = "GET", -- POST or GET
}

if not ok or code ~= 200 then
  ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
  ngx.say("Can't retrieve content")
  ngx.print("Status: ")
  ngx.say(status)
  ngx.exit(ngx.HTTP_OK)
end

local xml = require 'pl.xml'

function convert_solidot_rss(cont)
  local ns_end = cont:find('\n')
  local d = xml.parse(cont:sub(ns_end+1, -1))
  -- d[1] contains channel
  for item in d[1]:childtags() do
    if item.tag == "item" then
      for des in item:childtags() do
        if des.tag == "description" then
          local id = string.find(des[1], "<img width='1' height='1' src='http://solidot")
          if id then
            des[1] = string.sub(des[1], 1, id - 1)
          end
        end
      end
    end
  end
  local namespace = cont:sub(1, ns_end)
  return namespace .. tostring(d)
end

ngx.say(convert_solidot_rss(body))

