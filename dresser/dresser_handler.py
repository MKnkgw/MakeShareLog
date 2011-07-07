# encoding=utf-8

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
    self.mutex.lock(self.handle_rfid, rfid)
    self.mutex.unlock()

  # RFIDの信号が継続している時の処理
  def handle_update(self, rfid):
    self.mutex.lock(self.handle_rfid, rfid)
    self.mutex.unlock()

  def handle_rfid(self, rfid):
    print("Dresser: " + str(rfid))

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

    # 読み込んだJANコードの数が規定数に達したら写真を取る
    if len(self.jancodes) == REQUIRED_COUNT:
      # TODO 写真を取る処理を書く。
      #self.save()

  # RFIDからJANCODEへの変換を試みる
  def id2jancode(self, id):
    jancodes = settings.get("jancodes")
    if id in jancodes:
      return jancodes[id]
