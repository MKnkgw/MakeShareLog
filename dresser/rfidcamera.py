import sys
import os
import gc
import time
import socket
import asyncore
import mutex
from rfidclient import RfidClient

ANTHENA_NUM = 1
REQUIRED_COUNT = 3
WAIT_SEC  = 20
YAML_FILE = "jancodes.yaml"

class RfidCamera(RfidClient):
  def __init__(self, port):
    RfidClient.__init__(self, port)
    self.jancodes = []
    self.last_appear_time = time.time()
    self.rfid_mutex = mutex.mutex()

  def id2jancode(self, id):
    jancodes = yaml.load(open(YAML_FILE).read())
    if id in jancodes:
      return jancodes[id]

  def post_server(self, path, jancodes):
    command = "python upload.py %s %s %s %s" % (path, jancodes[0], jancodes[1], jancodes[2])
    print command
    os.system(command)


  def send_camera(self, command):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(1)
    r = sock.connect(('127.0.0.1', 12345))
    sock.send(command)

  def camera(self, path):
    try:
      command = '/save %s\n' % path 
      self.send_camera(command)
      while True:
        if os.path.isfile(path):
          break
        time.sleep(0.1)
      print command, self.jancodes
      self.post_server(path, self.jancodes)
      print "sent %s" % path
  
    except socket.error, e:
      print 'Error: %s' % e

  def save(self):
    self.send_camera("/run start")
    path = "data/%s.jpg" % time.strftime("%Y%m%d-%H%M%S")

    self.camera(path)

    self.jancodes = []

  def next_rfid(self, rfid):
    print rfid
    c = time.time()
    if c - self.last_appear_time > WAIT_SEC:
      self.jancodes = []
    state, anthena, raw, id = rfid
    jancode = self.id2jancode(id)
    if not (jancode in self.jancodes):
      self.jancodes.append(jancode)
    self.last_appear_time = c
    if len(self.jancodes) == REQUIRED_COUNT:
      self.save()
    self.rfid_mutex.unlock()

  def handle_update(self, rfid):
    pass

  def handle_disappear(self, rfid):
    pass

  def handle_appear(self, rfid):
    state, anthena, raw, id = rfid
    if anthena == str(ANTHENA_NUM):
      self.rfid_mutex.lock(self.next_rfid, rfid)



def main(port):
  camera = RfidCamera(port)
  camera.send_camera("/run start")
  asyncore.loop()

if __name__ == "__main__":
  time.sleep(5)
  if len(sys.argv) >= 2:
    main(int(sys.argv[1]))
  else:
    main(4321)
