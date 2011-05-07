require "rubygems"
require "dm-core"
require "dm-migrations"
require "win32ole"

$wsh = WIN32OLE.new("WScript.Shell")
$appname = "CosMapper"

DataMapper.setup(:default, {
  :adapter => "sqlite",
  :database => File.expand_path("cosmapper.db")
})

DataMapper.auto_upgrade!

class RfidTag
  include DataMapper::Resource

  property :rfid, String, :key => true
  property :jancode, String
end

DataMapper.auto_upgrade!

REQUIRED_RFID_COUNT = 3
RFID_RANGE_SEC = 5

load "rfid.rb"

def putslog(msg)
  puts msg
  log msg
end

def errbox(err)
  $wsh.Popup err, 5, "Error"
end

log "start CosMapper"
while true do
  #$wsh.AppActivate "ruby.exe"
  $wsh.AppActivate $appname

  puts "RFID�^�O��u���Ă�������"

  rfid = read_rfid_appear

  next unless rfid

  id = rfid[:raw]

  if RfidTag.get(id) then
    puts "�o�^�ς݂�RFID�^�O�ł�: #{id}"
    puts
    next
  end

  putslog "RFID�^�O: #{id}"
  puts

  #$wsh.AppActivate "ruby.exe"
  $wsh.AppActivate $appname
  puts "�o�[�R�[�h��ǂݍ���ł�������"

  jancode = gets.chomp!

  if tag = RfidTag.first(:jancode => jancode) then
    puts "RFID�^�O #{id} �œo�^�ς݂̃o�[�R�[�h�ł�: #{jancode}"
    puts
  end

  putslog "�o�[�R�[�h: #{jancode}"
  puts

  url = "http://hogel.org:38248/cosme/new/#{jancode}"
  log url

  system("explorer", url)

  tag = RfidTag.new(:rfid => id, :jancode => jancode)

  putslog "�ۑ��ł��܂���ł���: #{tag.inspect}" unless tag.save
  puts
end
