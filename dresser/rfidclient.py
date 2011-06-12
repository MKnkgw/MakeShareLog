import sys
import socket
import asyncore
import re

class RfidClient(asyncore.dispatcher):
  def __init__(self, port):
    self.re_status = re.compile(r"\w+,\w+,(\w+),(\d+),(\d+)")
    asyncore.dispatcher.__init__(self)
    self.create_socket(socket.AF_INET, socket.SOCK_STREAM)
    self.connect(("localhost", port))
    print 'connect port %s' % port

  def handle_appear(self, rfid):
    pass

  def handle_update(self, rfid):
    pass

  def handle_disappear(self, rfid):
    pass

  def handle_rfid(self, rfid):
    state, anthena, raw, id = rfid
    if state == "Appear":
      self.handle_appear(rfid)
    elif state == "Update":
      self.handle_update(rfid)
    elif state == "Disappear":
      self.handle_disappear(rfid)

  def handle_connect(self):
    pass

  def handle_close(self):
    pass

  def handle_read(self):
    status = self.recv(8192)
    match = self.re_status.match(status)
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

def main(port):
  camera = RfidClient(port)
  asyncore.loop()

if __name__ == "__main__":
  if len(sys.argv) >= 2:
    main(int(sys.argv[1]))
  else:
    main(4321)
