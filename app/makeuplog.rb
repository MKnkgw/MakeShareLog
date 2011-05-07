#!/usr/bin/ruby -rubygems

require "sinatra"
require "rack"
require "erb"
require "digest/md5"

load "models.rb"

load "conf.rb"

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

Dir.glob("controllers/*.rb").each{|rb| load(rb) }

use Login
use CosmeEdit
use Thumbnail

before do
  if !session[:user_name] then
    session[:goto] = request.url
    redirect "/login"
    halt
  end
end

#get "/*" do
#  erb params[:splat][0].to_sym
#end
