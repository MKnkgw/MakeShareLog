#!/usr/bin/ruby -rubygems

require "sinatra"
require "sinatra/reloader"
require "erb"
require "digest/md5"
require "json"
require "msgpack"

load "models.rb"

def create_thumb(src, dst, width)
  system("#$convert -resize #{width}x #{src} #{dst}")
end

def photo_thumb(photo, prefix, width)
  path = $datadir + "/" + photo.path
  ext = File.extname(path)
  thumb_path = "#$thumbdir/#{prefix}-#{photo.id}-#{width}-thumb#{ext}"
  if !File.exist?(thumb_path) || File.mtime(thumb_path) < File.mtime(path) then
    create_thumb(path, thumb_path, width)
  end
  thumb_path
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
