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
  print "python split_cheek.py face.jpg cheek.jpg"
  quit()

import cv

datadir = os.path.dirname(os.path.abspath(__file__)) + "/data"

src = sys.argv[1]
dst = sys.argv[2]

storage = cv.CreateMemStorage()

# 「目検出」のための教師データの読み込み
hc = cv.Load(datadir + "/haarcascades/haarcascade_eye.xml")
gc = cv.Load(datadir + "/haarcascades/haarcascade_mcs_mouth.xml")

# 画像の読み込み
img = cv.LoadImageM(src)

# 顔認識（速度のため適当にパラメータ）
eyes = cv.HaarDetectObjects(img, hc, storage, 1.1, 100, 0, (150, 100))
mouth = cv.HaarDetectObjects(img, gc, storage, 1.1, 100, 0, (300, 100))

# 検出した目のパーツから，頬の領域を切り出す
(x_e, y_e, w_e, h_e), n_e = eyes[0]
(x_m, y_m, w_m, h_m), n_m = mouth[0]
rect = (x_e - w_e / 3, y_e + 4 * h_e / 5, 11 * w_e / 6, y_m + h_m / 2 - y_e - h_e)
cheekimg = cv.GetSubRect(img, rect)

# 切り出した領域を保存
cv.SaveImage(dst, cheekimg)
