#!/usr/bin/ruby

photo = "photo.png"

if !system("./camera.exe", photo) then
  puts "error: camera.exe"
  exit $?
end

tags = ARGV[0] || ""

title = Time.now.strftime("%Y/%m/%d %H:%M:%S")

load "flickr.rb"

photo_id = upload(photo, title, tags)
log("photo id: #{photo_id}")

info = get_info(photo_id)

url = url(info)

log("upload: #{url}")

system("explorer", url)

puts photo_id
