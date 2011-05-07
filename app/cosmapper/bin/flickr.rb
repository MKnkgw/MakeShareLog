require "rubygems"
require "flickraw"
require "pit"
require "socket"

$pit = Pit.get("flickr", :require => {
  "apikey" => "Flickr API Key",
  "secret" => "Flickr Secret Key",
})

FlickRaw.api_key = $pit["apikey"]
FlickRaw.shared_secret = $pit["secret"]

unless $pit["token"]
  frob = flickr.auth.getFrob
  auth_url = FlickRaw.auth_url :frob => frob, :perms => "write"
  puts "access: #{auth_url}"
  STDIN.getc
  begin
    auth = flickr.auth.getToken :frob => frob
    login = flickr.test.login
    puts "You are now authenticated as #{login.username} with token #{auth.token}"
    Pit.set("flickr", :data => {
      "apikey" => $pit["apikey"],
      "secret" => $pit["secret"],
      "token" => auth.token
    })
  rescue FlickRaw::FailedResponse => e
    puts "Authentication failed : #{e.msg}"
    exit -1
  end
end

auth = flickr.auth.checkToken :auth_token => $pit["token"]

def upload(photo, title, tags)
  #puts "login as #{auth.user.username}"

  photo_id = flickr.upload_photo photo, :title => title, :tags => tags, :is_public => 0

  return photo_id
end

def get_info(photo_id)
  flickr.photos.getInfo(:photo_id => photo_id)
end

def raw_url(info)
  FlickRaw.url_b(info)
end

def url(info)
  info.urls[0]["_content"]
end

def log(message)
  File.open("log", "a"){|f|
    f.puts "#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}: #{message}"
  }
end
