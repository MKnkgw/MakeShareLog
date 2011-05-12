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

num = 1
while num < 13:
# 画像の読み込み
  photo_name = "faces/" + str(num) + ".jpg"
  img = cv.LoadImageM(photo_name)

# 顔認識（速度のため適当にパラメータ）
#faces = cv.HaarDetectObjects(img, hc, storage)
  faces = cv.HaarDetectObjects(img, hc, storage, 1.1, 100, 0, (100, 100))

# (R, G, B)
  color = (255, 255, 255)

# 検出した目のパーツから，頬の位置を切り取る
# 四角で囲む
  for (x, y, w, h), n in faces:
    p1 = (x - w / 3, y + 4 * h / 5)
    p2 = (x + w + w / 2, y + h + 4 * h / 3)
    cv.Rectangle(img, p1, p2, color)

# 四角を描いた画像を保存
  cv.SaveImage("faces_detected_cheek/" + str(num) + ".jpg", img)
  print num
  num += 1
print "End"
