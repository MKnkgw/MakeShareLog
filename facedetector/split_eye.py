#!/usr/bin/python
# vim: fileencoding=utf-8:

# *参考 
#  * リファレンス
# http://opencv.jp/opencv-2.2/py/objdetect_cascade_classification.html#haar-feature-based-cascade-classifier-for-object-detection
#  * 解説ページ（C言語）
# http://www.aianet.ne.jp/~asada/prog_doc/opencv/opencv_obj_det_img.htm

import sys
import os

if len(sys.argv) != 3:
  print "python split_eye.py face.jpg eye.jpg"
  quit()

import cv

datadir = os.path.dirname(os.path.abspath(__file__)) + "/data"

src = sys.argv[1]
dst = sys.argv[2]

storage = cv.CreateMemStorage()

# 「目検出」のための教師データの読み込み
hc = cv.Load(datadir + "/haarcascades/haarcascade_eye.xml")

# 画像の読み込み
img = cv.LoadImageM(src)

# 顔認識（速度のため適当にパラメータ）
eyes = cv.HaarDetectObjects(img, hc, storage, 1.1, 100, 0, (150, 100))

# 検出したパーツの領域を切り出す
(x, y, w, h), n = eyes[0]
rect = (x - w / 3, y - w / 3, w + 5 * w / 6, h + w / 3)
eyeimg = cv.GetSubRect(img, rect)

# 切り出した領域を保存
cv.SaveImage(dst, eyeimg)
