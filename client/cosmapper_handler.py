# encoding=utf-8
import mutex
from rfidclient import RfidHandler

class CosmapperHandler(RfidHandler):
  def __init__(self, settings, camera):
    self.settings = settings
    self.camera = camera
    self.mutex = mutex.mutex()

  # RFIDの信号が現れた時の処理
  def handle_appear(self, rfid):
    state, anthena, raw, id = rfid

    # register_jancodeの処理が同時に複数行われないようにmutexでロック
    self.mutex.lock(self.register_jancode, id)
    # 処理が終わったのでロックを解除
    self.mutex.unlock()

  def handle_update(self, rfid):
    state, anthena, raw, id = rfid

    # register_jancodeの処理が同時に複数行われないようにmutexでロック
    self.mutex.lock(self.register_jancode, id)
    # 処理が終わったのでロックを解除
    self.mutex.unlock()

  # RFIDからJANCODEへの変換を試みる
  def id2jancode(self, id):
    jancodes = self.settings.get("jancodes")
    if jancodes and id in jancodes:
      return jancodes[id]

  def register_jancode(self, id):
    # 読み込んだRFIDに対応するJANコードが取れなかったら登録処理
    if not self.id2jancode(id):
      # カメラ画像更新処理を止めるよう指示
      self.camera.event_set("run", "stop")

      # RFIDに対応するJANコードを登録するようカメラ画面に指示
      self.camera.event_set("register-jancode", id)
