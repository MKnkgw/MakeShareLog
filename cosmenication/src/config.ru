#!/usr/bin/ruby -rubygems

require "app.rb"

$port = 80
$appname = "COSMEnication"
$face_thumb_width = 200
$cosme_thumb_width = 100

$face_mainphoto_width = 900

$datadir = "../data"
$photodir = "#$datadir/photo"
$thumbdir = "#$datadir/thumb"

$description_length = 100

$convert = "c:/prg/ImageMagick-6.6.8-Q16/convert.exe"

$facedetector_command_prefix = "python ../../facedetector"
$split_eye = "#$facedetector_command_prefix/split_eye.py"
$split_cheek = "#$facedetector_command_prefix/split_cheek.py"
$split_mouth = "#$facedetector_command_prefix/split_mouth.py"

$KCODE = "UTF8"

Core.run! :port => $port
