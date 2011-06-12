load "models.rb"

$initdir = "../data/init"

$eye = PartType.first(:name => "Eye")
$cheek = PartType.first(:name => "Cheek")
$lip = PartType.first(:name => "Lip")
$face = PartType.first(:name => "Face")
$parts = [$face, $lip, $eye, $cheek]

accounts = File.readlines("#$initdir/account.txt")
accounts[1...accounts.size].each{|line|
  line.chomp!
  name, *pubs = line.split(",")
  user = User.first_or_create(
    :name => name,
    :pass => Digest::MD5.hexdigest(name)
  )

  group = Group.first_or_create(
    :forall => true,
    :user_id => user.id,
    :name => "通常の公開範囲",
    :description => "同じ化粧品を使っている人に対する公開設定"
  )
  pubs.each_with_index{|x, i|
    publish = x == "1"
    STDERR.puts "#{name} #{PartType.get($parts[i].id).name} #{publish}"
    PublicSetting.first_or_create(
      :public => publish,
      :group_id => group.id,
      :part_type_id => $parts[i].id
    )
  }
}

def get(n);end
def post(n);end
def halt(e);end
$photodir = "../data/photo"
require "../src/controllers/nologin/cosme"
require "json"
nologin = NoLogin.new
cosmetics = File.readlines("#$initdir/cosmetics.csv")
RFIDs = {}
cosmetics[1...cosmetics.size].each{|line|
  line.chomp!
  rfid, jan, partname, brandname, name, colorname, url, imgpath = line.split(",")
  cosme = nologin.first_or_register(jan)
  RFIDs[rfid.to_i] = cosme
}

Dir.glob("#$initdir/photo/*/*/*").each{|photoset_path|
  unless photoset_path =~ /\/([^\/]+)\/\d{3}\/(\d{4})(\d{2})(\d{2})-(\w+)$/ then
    abort("unknown photoset_path #{photoset_path}") 
  end
  user = User.first(:name => $1)
  year = $2.to_i
  month = $3.to_i
  day = $4.to_i
  level_name = $5.capitalize

  time = Time.local(year, month, day)

  photoset = PhotoSet.first_or_create(
    :created_at => time,
    :user_id => user.id
  )

  File.read("#{photoset_path}/tags").split(", ").map{|x| x.to_i}.each{|tag|
    cosme = RFIDs[tag]

    tagging = CosmeticTagging.first_or_create(
      :photo_set_id => photoset.id,
      :cosmetic_id => cosme.id
    )

    ucosme = UserCosmetic.first_or_create(
      :user_id => user.id,
      :cosmetic_id => cosme.id
    )
  }

  Dir.glob("#{photoset_path}/*.*").each{|photo_path|
    unless photo_path =~ /(\w+).\w+$/ then
      abort("unknown photo_path #{photo_path}")
    end
    #if photo_path =~ /((?:cheek|lip|eye)\.jpg)$/ then
    #  face = photo_path.sub(/((?:cheek|lip|eye)\.jpg)$/, "face.jpg")
    #end
    part_name = $1.capitalize
    part = PartType.first(:name => part_name)
    abort("unknown part type #{part_name}") if !part

    photo = Photo.first_or_create(
      :path => photo_path,
      :created_at => time
    )
    face = FacePhoto.first_or_create(
      :photo_id => photo.id,
      :photo_set_id => photoset.id,
      :part_type_id => part.id,
      :user_id => user.id
    )
  }
}
