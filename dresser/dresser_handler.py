import sys
import os
import gc
import time
import socket
import mutex
import yaml
from rfidclient import RfidHandler

REQUIRED_COUNT = 3
AVAILABLE_WAIT_SEC  = 20
YAML_FILE = "jancodes.yaml"

class DresserHandler(RfidHandler):
  def __init__(self, settings):
    self.settings = settings
    self.camera = camera
    self.mutex = mutex.mutex()

    self.jancodes = []
    self.last_appear_time = time.time()

  def handle_appear(self, rfid):
    state, anthena, raw, id = rfid
    print("Dresser: " + str(rfid))
    self.mutex.lock(self.next_rfid, rfid)

  def id2jancode(self, id):
    jancodes = settings.get("jancodes")
    if id in jancodes:
      return jancodes[id]

  def next_rfid(self, rfid):
    c = time.time()
    if c - self.last_appear_time > AVAILABLE_WAIT_SEC:
      self.jancodes = []

    state, anthena, raw, id = rfid
    jancode = self.id2jancode(id)
    if not (jancode in self.jancodes):
      self.jancodes.append(jancode)
    self.last_appear_time = c
    if len(self.jancodes) == REQUIRED_COUNT:
      print(self.jancodes)
      #self.save()
    self.mutex.unlock()
