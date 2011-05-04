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

def new_genuser(name)
  new_user(name, name, false, UserLevel[0].id)
end

def find_or_create(klass, args)
  klass.first(args) || klass.create(args)
end

newbie = UserLevel.create(:name => "Newbie", :value => 0)
middle = UserLevel.create(:name => "Middle", :value => 1)
expert = UserLevel.create(:name => "Expert", :value => 2)

eye = PartType.create(:name => "Eye")
cheek = PartType.create(:name => "Cheek")
lip = PartType.create(:name => "Lip")
face = PartType.create(:name => "Face")

new_user("hogelog", "hogelog", true, expert.id)
new_user("MKnkgw", "MKnkgw", true, newbie.id)
new_genuser("tbyk_and")
new_genuser("ankorobe")
new_genuser("chihiroms")
new_genuser("ch1h0")
new_genuser("Maolol")
new_genuser("ihomhom")
new_genuser("azucado")
new_genuser("mijink0")
new_genuser("marina")
new_genuser("kitty_mimmy")
new_genuser("kisaroom")

cosmetics = File.readlines("../data/cosmetics.csv")
cosmetics[1...cosmetics.size].each{|line|
  rfidcode, jan, partname, brandname, name, colorname = line.split(",")
  part = PartType.first(:name => partname.capitalize)
  brand = find_or_create(Brand, :name => brandname)
  color = find_or_create(Color, :name => colorname)

  cosme = Cosmetic.new(
    :jancode => jan,
    :part_type_id => part.id,
    :brand_id => brand.id,
    :name => name,
    :color_id => color.id
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
    :user_id => user.id,
    :user_level_id => level.id
  )
  abort("cannot save #{photoset_path}") if !photoset.save

  File.read("#{photoset_path}/tags").split(", ").map{|x| x.to_i}.each{|tag|
    rfid = Rfid.first(:rfid => tag)
    tagging = CosmeticTagging.new(
      :photo_set_id => photoset.id,
      :cosmetic_id => rfid.cosmetic_id
    )
    abort("cannot save cosmetic rfid #{tag}") if !tagging.save
  }

  Dir.glob("#{photoset_path}/*.*").each{|photo_path|
    unless photo_path =~ /(\w+).\w+$/ then
      abort("unknown photo_path #{photo_path}")
    end
    part_name = $1.capitalize
    part = PartType.first(:name => part_name)
    abort("unknown part type #{part_name}") if !part

    photo = Photo.new(
      :path => photo_path,
      :created_at => time,
      :photo_set_id => photoset.id,
      :part_type_id => part.id,
      :user_id => user.id
    )
    abort("cannot save #{photo_path}") if !photo.save
  }
}
