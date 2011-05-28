load "models.rb"

def new_user(name, pass, admin, level)
  user = User.new(
    :name => name,
    :pass => Digest::MD5.hexdigest(pass),
    :admin => admin,
    :user_level_id => level
  )
  
  abort("cannot insert #{name}") if !user.save
  user
end

$levels = {}
$levels["newbie"] = newbie = UserLevel.create(:name => "Newbie", :value => 0)
$levels["middle"] = middle = UserLevel.create(:name => "Middle", :value => 1)
$levels["expert"] = expert = UserLevel.create(:name => "Expert", :value => 2)

$eye = PartType.create(:name => "Eye")
$cheek = PartType.create(:name => "Cheek")
$lip = PartType.create(:name => "Lip")
$face = PartType.create(:name => "Face")

new_user("hogelog", "hogelog", true, expert.id)
accounts = File.readlines("../data/account.txt")
accounts[1...accounts.size].each{|line|
  line.chomp!
  name, level, *pubs = line.split(",")
  user = new_user(name, name, false, $levels[level].id)
 
  pubs.each_with_index{|x, i|
    pub = PublicSetting.new(
      :public => x == "1",
      :user_id => user.id,
      :part_type_id => [$face, $lip, $eye, $cheek][i].id
    )
    abort("cannot save public setting #{user.name}") if !pub.save
  }
}

cosmetics = File.readlines("../data/cosmetics.csv")
cosmetics[1...cosmetics.size].each{|line|
  line.chomp!
  rfidcode, jan, partname, brandname, name, colorname, url, imgpath = line.split(",")
  part = PartType.first(:name => partname.capitalize)
  brand = find_or_create(Brand, :name => brandname)
  color = find_or_create(Color, :name => colorname)

  unless photo = find_or_create(Photo, :path => imgpath) then
    abort("cannot save cosmetic photo #{imgpath}")
  end

  cosme = Cosmetic.new(
    :jancode => jan,
    :part_type_id => part.id,
    :brand_id => brand.id,
    :name => name,
    :color_id => color.id,
    :url => url,
    :photo_id => photo.id
  )

  abort("cannot save cosmetic #{name}") if !cosme.save

  rfid = Rfid.new(:rfid => rfidcode.to_i, :cosmetic_id => cosme.id)
  abort("cannot save rfid #{rfid}") if !rfid.save
}



Dir.glob("../data/photo/*/*/*").each{|photoset_path|
  unless photoset_path =~ /\/([^\/]+)\/\d{3}\/(\d{4})(\d{2})(\d{2})-(\w+)$/ then
    abort("unknown photoset_path #{photoset_path}") 
  end
  user = User.first(:name => $1)
  user_id = user.id
  year = $2.to_i
  month = $3.to_i
  day = $4.to_i
  level_name = $5.capitalize
  level_name = "Middle" if level_name == "Midle"

  time = Time.local(year, month, day)

  level = UserLevel.first(:name => level_name)
  abort("unknown level name #{photoset_path}") if !level

  photoset = PhotoSet.new(
    :created_at => time,
    :user_id => user_id,
    :user_level_id => level.id
  )
  abort("cannot save #{photoset_path}") if !photoset.save

  File.read("#{photoset_path}/tags").split(", ").map{|x| x.to_i}.each{|tag|
    rfid = Rfid.first(:rfid => tag)
    cosmetic_id = rfid.cosmetic_id
    tagging = CosmeticTagging.new(
      :photo_set_id => photoset.id,
      :cosmetic_id => cosmetic_id
    )
    abort("cannot save cosmetic rfid #{tag}") if !tagging.save

    if !OwnCosmetic.get(user_id, cosmetic_id) then
      own = OwnCosmetic.new(
        :user_id => user_id,
        :cosmetic_id => cosmetic_id
      )
      abort("cannot save own cosmetic #{cosmetic_id}") if !own.save
    end
  }

  Dir.glob("#{photoset_path}/*.*").each{|photo_path|
    unless photo_path =~ /(\w+).\w+$/ then
      abort("unknown photo_path #{photo_path}")
    end
    part_name = $1.capitalize
    part = PartType.first(:name => part_name)
    abort("unknown part type #{part_name}") if !part

    photo = Photo.new(
      :path => photo_path.sub(/^..\/data\//, ""),
      :created_at => time
    )
    abort("cannot save photo #{photo_path}") if !photo.save
    face = FacePhoto.new(
      :photo_id => photo.id,
      :photo_set_id => photoset.id,
      :part_type_id => part.id,
      :user_id => user.id
    )
    abort("cannot save face photo #{photo_path}") if !face.save
  }
}
