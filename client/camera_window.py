import pygame
import time
from threading import Thread, Event

from camera import Camera

GUI_UPDATE_WAIT = 0.2

class CameraWindow(Thread):
  def __init__(self, settings):
    self.settings = settings
    self.events = {
        "shutter": Event(),
        "register-jancode": Event(),
        "quit": Event(),
        "run": Event()
    }
    Thread.__init__(self)

  def run(self):
    self.camera = Camera()
    while not self.event("quit"):
      time.sleep(GUI_UPDATE_WAIT)

      run = self.event("run")
      if run and run.arg == "start":
        self.camera.update()

      if self.event("shutter"):
        path = self.event("shutter").arg
        self.event_clear("shutter")
        self.event_set("run", "start")
        self.camera.shutter(path)
        self.event_set("run", "stop")

      if self.event("write"):
        self.camera.write(self.event("write").arg)
        self.event_clear("write")

      if self.event("register-jancode"):
        self.register_jancode(self.event("register-jancode").arg)
        self.event_clear("register-jancode")

      event = self.camera.event()

      if event.type == pygame.NOEVENT:
        continue

      if event.type == pygame.KEYDOWN:
        name = pygame.key.name(event.key)
        if event.key == pygame.K_ESCAPE:
          self.event_set("quit", True)
        elif event.key == pygame.K_p:
          path = "%s.jpg" % time.strftime("%Y%m%d-%H%M%S")
          self.camera.save(path)
        elif event.key == pygame.K_r:
          if run and run.arg == "start":
            self.event_set("run", "stop")
          else:
            self.event_set("run", "start")

  def event_set(self, name, arg):
    if name in self.events and self.events[name]:
      self.events[name].arg = arg
      self.events[name].set()

  def event_clear(self, name):
    if name in self.events and self.events[name]:
      self.events[name].clear()

  def event(self, name):
    if name in self.events and self.events[name].isSet():
      return self.events[name]

  def register_jancode(self, id):
    print("register jancode")
    self.camera.fill()
    self.camera.write("Unknown RFID: " + id + ". Scan JAN-CODE.")
    jancode = self.read_jancode()
    print("read jancode: " + jancode)
    jancodes = self.settings.get("jancodes")
    jancodes[id] = jancode
    self.settings.set("jancodes", jancodes)
    self.settings.save()
    self.camera.fill()
    self.camera.write("RFID: '" + id + ".    JAN-CODE: " + jancode + ".")
    time.sleep(5)
    self.event_set("run", "start")

  def read_jancode(self):
    jancode = ""
    while not self.event("quit"):
      event = self.camera.event()
      if event.type == pygame.KEYDOWN:
        if event.key == pygame.K_RETURN:
          return jancode
        name = pygame.key.name(event.key)
        jancode += name
        self.camera.fill()
        self.camera.write(jancode)
