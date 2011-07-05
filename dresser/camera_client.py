import time
import socket
import os

class CameraClient:
  def __init__(self):
    self.send_camera("/run start")

  def send_camera(self, command):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(1)
    r = sock.connect(('127.0.0.1', 12345))
    sock.send(command)

  def write(self, str):
    self.send_camera("/run stop")
    self.send_camera("/write " + str)

  def save(self):
    self.send_camera("/run start")
    path = "data/%s.jpg" % time.strftime("%Y%m%d-%H%M%S")

    self.shutter(path)

  def shutter(self, path):
    try:
      command = '/save %s\n' % path 
      self.send_camera(command)
      while True:
        if os.path.isfile(path):
          break
        time.sleep(0.1)
      print command, self.jancodes
      self.upload(path, self.jancodes)
      print "sent %s" % path
  
    except socket.error, e:
      print 'Error: %s' % e

  def upload(self, path, jancodes):
    command = "python upload.py %s %s %s %s" % (path, jancodes[0], jancodes[1], jancodes[2])
    print("upload: " + command)
    os.system(command)
