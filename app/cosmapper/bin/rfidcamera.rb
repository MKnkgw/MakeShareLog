
REQUIRED_RFID_COUNT = 3
RFID_RANGE_SEC = 5

load "rfid.rb"
load "flickr.rb"

while true do
  puts "wait rfid ..."
  ids = []
  last_time = Time.now
  while ids.size != REQUIRED_RFID_COUNT do
    rfid = read_rfid_appear
    id = rfid[:id]
    if !ids.include?(id) then
      c = Time.now
      if c - last_time > RFID_RANGE_SEC then
        ids = []
      end
      ids.push(id)
      last_time = c
    end
  end

  title = Time.now.strftime("%Y%m%d%H%M%S")
  photo = "data\\"+title+".jpg"
  tags = ids.join(" ")

  puts "tags: #{tags}"

  log photo
  log "tags: #{tags}"

  puts "camera #{photo}"
  if !system("./camera.exe", photo) then
    puts "error: camera.exe"
    exit $?
  end

  puts "uploading #{photo} ..."
  photo_id = upload(photo, title, tags)
  log("photo id: #{photo_id}")

  info = get_info(photo_id)

  url = url(info)

  puts "upload #{url}"
  log("upload: #{url}")

  system("explorer", url)

end
