#!/usr/bin/python
# vim: fileencoding=utf-8:

# *参考 
#  * リファレンス
# http://opencv.jp/opencv-2.2/py/objdetect_cascade_classification.html#haar-feature-based-cascade-classifier-for-object-detection
#  * 解説ページ（C言語）
# http://www.aianet.ne.jp/~asada/prog_doc/opencv/opencv_obj_det_img.htm

import cv

storage = cv.CreateMemStorage()

# 「目検出」のための教師データの読み込み
hc = cv.Load("C:/OpenCV2.2/data/haarcascades/haarcascade_eye.xml")
gc = cv.Load("C:/OpenCV2.2/data/haarcascades/haarcascade_mcs_mouth.xml")

num = 1
while num < 13:
# 画像の読み込み
  photo_name = "faces/" + str(num) + ".jpg"
  img = cv.LoadImageM(photo_name)

# 顔認識（速度のため適当にパラメータ）
#faces = cv.HaarDetectObjects(img, hc, storage)
  eyes = cv.HaarDetectObjects(img, hc, storage, 1.1, 100, 0, (200, 100))
  mouth = cv.HaarDetectObjects(img, gc, storage, 1.1, 100, 0, (300, 100))

# (R, G, B)
  color = (255, 255, 255)

# 検出した目のパーツから，頬の位置を切り取る
# 四角で囲む
  (x_e, y_e, w_e, h_e), n_e = eyes[0]
  (x_m, y_m, w_m, h_m), n_m = mouth[0]
  p1 = (x_e - w_e / 3, y_e + 4 * h_e / 5)
  p2 = (x_e + w_e + w_e / 2, y_m + h_m / 2)
  cv.Rectangle(img, p1, p2, color)

# 四角を描いた画像を保存
  cv.SaveImage("faces_detected_cheek/" + str(num) + ".jpg", img)
  print num
  num += 1
print "End"
