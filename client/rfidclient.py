import sys
import socket
import asyncore
import re

class RfidHandler:
  def handle_appear(self, rfid):
    pass

  def handle_update(self, rfid):
    pass

  def handle_disappear(self, rfid):
    pass

class RfidClient(asyncore.dispatcher):
  def __init__(self, port):
    self.re_status = re.compile(r"\w+,\w+,(\w+),(\d+),(\d+)")
    asyncore.dispatcher.__init__(self)
    self.create_socket(socket.AF_INET, socket.SOCK_STREAM)
    self.connect(("localhost", port))
    self.handlers = []
    print 'connect port %s' % port

  def add_handler(self, handler):
    self.handlers.append(handler)

  def handle_rfid(self, rfid):
    state, anthena, raw, id = rfid

    for handler in self.handlers:
      if state == "Appear":
        handler.handle_appear(rfid)
      elif state == "Update":
        handler.handle_update(rfid)
      elif state == "Disappear":
        handler.handle_disappear(rfid)

  def handle_connect(self):
    pass

  def handle_close(self):
    pass

  def handle_read(self):
    status = self.recv(8192)
    for line in status.split("\n"):
      match = self.re_status.match(line)
      if match:
        state = match.group(1)
        anthena = match.group(2)
        raw = match.group(3)
        id = raw[-4:]
        self.handle_rfid((state, anthena, raw, id))

  def writable(self):
    return False

  def handle_write(self):
    pass
