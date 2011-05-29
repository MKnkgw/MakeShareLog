#!/usr/bin/ruby -rubygems

require "sinatra/reloader"

require "app.rb"

$port = 80
$appname = "COSMEnication"
$face_thumb_width = 200
$cosme_thumb_width = 100

$face_mainphoto_width = 900

$datadir = "../data"
$thumbdir = "#$datadir/thumb"
$convert = "c:/prg/ImageMagick-6.6.8-Q16/convert.exe"

MakeupCore.run! :port => $port
