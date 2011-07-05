import mutex
from rfidclient import RfidHandler

class CosmapperHandler(RfidHandler):
  def __init__(self, settings, camera):
    self.settings = settings
    self.camera = camera
    self.mutex = mutex.mutex()

  def handle_appear(self, rfid):
    state, anthena, raw, id = rfid
    print("Cosmapper: " + str(rfid))
    jancode = self.id2jancode(id)
    if not jancode:
      jancodes = self.settings.get("jancodes")
      self.camera.event_set("run", "stop")
      self.camera.event_set("register-jancode", id)

  def id2jancode(self, id):
    print("id: " + str(id))
    jancodes = self.settings.get("jancodes")
    print("jancodes: " + str(jancodes))
    if jancodes and id in jancodes:
      return jancodes[id]
