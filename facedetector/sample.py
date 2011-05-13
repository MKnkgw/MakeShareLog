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

# 画像の読み込み
#img = cv.LoadImageM("face.jpg")
iplimg = cv.LoadImage("face.jpg")

# 顔認識（速度のため適当にパラメータ）
#faces = cv.HaarDetectObjects(img, hc, storage)
eye = cv.HaarDetectObjects(iplimg, hc, storage, 1.1, 100, 0, (200, 100))
  
# (R, G, B)
color = (255, 255, 255)

# 検出したパーツそれぞれの領域を
# 四角で囲む
(x, y, w, h), n = eye[0]
p1 = (x - w / 3, y - w / 3)
p2 = (x + w + w / 2, y + h)
#cv.Rectangle(img, p1, p2, color)
#cv.SaveImage("face_detected_line.jpg", img)

rect = (x - w / 3, y - w / 3, w + 5 * w / 6, h + w / 3)
cv.SetImageROI(iplimg, rect)
# 四角を描いた画像を保存
cv.SaveImage("face_detected.jpg", iplimg)
