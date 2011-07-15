import sys
import requests

UPLOAD_URL = "http://hogel.org:38248/photo/upload/MKnkgw"
#UPLOAD_URL = "http://localhost/photo/upload/hogelog"

argv = sys.argv
if len(argv) != 5:
  sys.exit()

path = argv[1]
jancode1 = argv[2]
jancode2 = argv[3]
jancode3 = argv[4]
#print path, jancode1, jancode2, jancode3

with open(path, "rb") as photo:
  #print photo
  req = requests.post(UPLOAD_URL, data = {
    "jancode1": jancode1,
    "jancode2": jancode2,
    "jancode3": jancode3,
  }, files = {
    "photo_file": photo
  })

print("sent: %s" % path)
