require "socket"

$rfid_server = TCPSocket.open("127.0.0.1", 4321)

$rfid_responce_regex = /\w+,\w+,(\w+),(\d+),(\d+)/

def log(message)
  File.open("log", "a"){|f|
    f.puts "#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}: #{message}"
  }
end

def read_rfid_raw
  $rfid_server.gets
end

def read_rfid
  res = read_rfid_raw
  match = $rfid_responce_regex.match(res)
  if match then
    raw = match[3]
    {
      :state => match[1],
      :anthena => match[2],
      :raw => raw,
      :id => raw[raw.size-4 ... raw.size],
    }
  end
end

def read_rfid_appear
  while rfid = read_rfid do
    if rfid[:state] == "Appear" then
      return rfid
    end
  end
end

def read_rfid_update
  while rfid = read_rfid do
    if rfid[:state] == "Update" then
      return rfid
    end
  end
end

def read_rfid_disappear
  while rfid = read_rfid do
    if rfid[:state] == "Disappear" then
      return rfid
    end
  end
end


at_exit{
  $rfid_server.close
}
