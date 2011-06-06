import sys
import socket
import re
import time
from threading import Thread, Event
from camera import Camera
import pygame

CMD_RE = re.compile("^/(\w+)(?: (.+))?$")

WAIT = 0.2

class CameraServer(Thread):
  def __init__(self, port):
    self.events = {
        "photo": Event(),
        "save": Event(),
        "quit": Event(),
        "run": Event()
    }
    self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    self.sock.bind(("localhost", port))
    self.sock.listen(1)
    print 'listen port %s' % port

    Thread.__init__(self)

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

  def run(self):
    while not self.event("quit"):
      time.sleep(WAIT)
      connect, address = self.sock.accept()
      line = connect.recv(8192).rstrip()
      match = CMD_RE.search(line)
      if match:
        name = match.group(1)
        arg = match.group(2)
        self.event_set(name, arg)
      connect.close()

def main(port):
  server = CameraServer(port)
  server.start()
  camera = Camera()
  while server.isAlive():
    time.sleep(WAIT)
    if server.event("run"):
      for event in camera.update():
        if event.type == pygame.KEYDOWN:
          if event.key == pygame.K_ESCAPE:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.connect(("localhost", port))
            sock.send("/quit")
            server.join()
            sys.exit()
          elif event.key == pygame.K_p:
            path = "%s.jpg" % time.strftime("%Y%m%d-%H%M%S")
            server.event_set("save", path)

      if server.event("save"):
        camera.save(server.event("save").arg)
        server.event_clear("save")

if __name__ == "__main__":
  if len(sys.argv) >= 2:
    main(int(sys.argv[1]))
  else:
    main(12345)

# vim: sw=2 ts=2 et:
