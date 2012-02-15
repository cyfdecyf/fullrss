Recommend fivefilters now
=========================

[fivefilvers](http://fivefilters.org/content-only/) provides the service to
convert partial RSS to full content RSS. They use Readability's content api to
get the full content. So it should be reliable than doing it manually.

This project will still be useful for some simple tasks. Like removing the
footnote at the end of each item, etc.

Why
===

Han Han (韩寒) writes great article about the China's problem. [His
blog](http://blog.sina.com.cn/twocold) is on Sina which does export full RSS. So
I created this to convert the excerpt RSS to a FULL RSS.

Thanks to [hpricot](https://github.com/hpricot/hpricot), this is really easy to do.

Usage
=====

`fullrss.rb` contains the logic to convert RSS feeds.

Specify the source and a function to process the items in an RSS feed when
create instance of `FullRSS::RSS`. `RSS#convert` will call the process function
on each item in the RSS feed.

To get full RSS quickly and avoid client time out, you may need to cache
content. If cache is enabled, it will smiply stores the content returned by the
process function as text file under the `content` directory.

`RSS#cgi_output` can be used in an cgi script to output the converted RSS feed.

