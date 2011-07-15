# encoding=utf-8

import os
import time
import mutex
from rfidclient import RfidHandler

REQUIRED_COUNT = 3
AVAILABLE_WAIT_SEC  = 20
YAML_FILE = "jancodes.yaml"

class DresserHandler(RfidHandler):
  def __init__(self, settings, camera):
    self.settings = settings
    self.camera = camera
    self.mutex = mutex.mutex()

    self.jancodes = []
    self.last_appear_time = time.time()

  # RFIDの信号が現れた時の処理
  def handle_appear(self, rfid):
    # 同時に一つの処理だけがhandle_rfidを実行
    self.mutex.lock(self.handle_lock_appear, rfid)
    self.mutex.unlock()

  def handle_lock_appear(self, rfid):
    #print("Dresser: " + str(rfid))

    c = time.time()
    if c - self.last_appear_time > AVAILABLE_WAIT_SEC:
      self.jancodes = []

    state, anthena, raw, id = rfid
    jancode = self.id2jancode(id)

    # RFIDに対応するJANコードが取れなかったら何もしない
    if not jancode:
      return

    # まだ読んでいないJANコードだったら記憶
    if not (jancode in self.jancodes):
      self.jancodes.append(jancode)
    self.last_appear_time = c


  # RFIDの信号が継続している時の処理
  def handle_update(self, rfid):
    # 同時に一つの処理だけがhandle_rfidを実行
    self.mutex.lock(self.handle_lock_update, rfid)
    self.mutex.unlock()

    # 読み込んだJANコードの数が規定数に達したら写真を取る
    if len(self.jancodes) == REQUIRED_COUNT:
      # 写真を取る処理
      self.shutter()

  def handle_lock_update(self, rfid):
    c = time.time()
    self.last_appear_time = c

  # RFIDからJANCODEへの変換を試みる
  def id2jancode(self, id):
    jancodes = self.settings.get("jancodes")
    if id in jancodes:
      return jancodes[id]

  def shutter(self):
    path = "data/%s.jpg" % time.strftime("%Y%m%d-%H%M%S")

    # カメラに写真を取るように指示
    self.camera.event_set("shutter", path)
    # 写真が保存されるまでループ
    while True:
      if os.path.isfile(path):
        break
      time.sleep(0.1)
    ## 写真が保存されたら写真をアップロード
    self.upload(path)
    self.jancodes = []

  # 与えられたパスの画像をアップロード
  def upload(self, path):
    code1, code2, code3 = self.jancodes
    command = "python upload.py %s %s %s %s" % (path, code1, code2, code3)
    print command
    os.system(command)

