#!/usr/bin/ruby -rubygems

require "open-uri"
require "json"

if ARGV.length < 2 then
  puts "example:\n  $ download.rb http://www.st-hatena.com/users/ho/hogelog/profile.gif hoge.gif"
  exit
end

info = {}
info["url"] = url = ARGV[0]
info["path"] = out = ARGV[1]

open(url){|res|
  File.open(out, "wb"){|file|
    file.write(res.read)
    file.flush
  }
  info["content_type"] = res.content_type
  info["charset"] = res.charset
}

STDOUT.print info.to_json
STDOUT.flush
