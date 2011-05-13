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
  print "python split_mouth.py face.jpg mouth.jpg"
  quit()

import cv

datadir = os.path.dirname(os.path.abspath(__file__)) + "/data"

src = sys.argv[1]
dst = sys.argv[2]

storage = cv.CreateMemStorage()

# 「目検出」のための教師データの読み込み
hc = cv.Load(datadir + "/haarcascades/haarcascade_mcs_mouth.xml")

# 画像の読み込み
img = cv.LoadImageM(src)

# 顔認識（速度のため適当にパラメータ）
mouth = cv.HaarDetectObjects(img, hc, storage, 1.1, 100, 0, (300, 100))

# 検出した口の領域を切り出す
(x, y, w, h), n = mouth[0]
rect = (x - w / 5, y, w + 2 * w / 5, h)
mouthimg = cv.GetSubRect(img, rect)

# 四角を描いた画像を保存
cv.SaveImage(dst, mouthimg)
