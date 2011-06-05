#!/usr/bin/ruby -rubygems

require "sinatra"
require "sinatra/reloader"
require "erb"
require "digest/md5"
require "json"
require "msgpack"

load "models.rb"

def create_thumbnail(photo, width)
  photo_path = "#{$datadir}/#{photo.path}" 
  thumb_path = "#$thumbdir/#{Thumbnail.last_insert_id}"
  system("#$convert -resize #{width}x #{photo_path} #{thumb_path}")

  Thumbnail.create(:path => thumb_path, :width => width.to_i, :photo_id => photo.id)
end

def upload_photo_file(tempfile, name)
  path = "#$datadir/#{name}"
  File.open(path, "wb"){|file|
    file.write(tempfile.read)
  }
  photo = Photo.new(:path => path)

  photo.save ? photo : nil
end

load "controllers/core.rb"
