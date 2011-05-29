import socket
from sys import argv

argv.pop(0)

arg = " ".join(argv)
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.settimeout(1)
try:
  r = sock.connect(('127.0.0.1', 12345))
  print('%s\n' % arg)
  sock.send('%s\n' % arg)
except socket.error, e:
  print 'Error: %s' % e
