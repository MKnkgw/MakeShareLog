require "dm-core"
require "dm-migrations"
require "dm-types"
#require "dm-validations"

DataMapper.setup(:default, {
  :adapter => "sqlite",
  :database => File.expand_path("development.db")
})

TimeProc = proc{|r, p| Time.now }

class User
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :allow_nil => false
  property :pass, String, :allow_nil => false
  property :admin, Boolean, :allow_nil => false, :default => false
  property :created_at, DateTime, :default => TimeProc, :allow_nil => false

  has n, :photo_sets
  has n, :own_cosmetics
  belongs_to :user_level
end

class UserLevel
  include DataMapper::Resource

  property :id, Serial
  property :value, Integer, :allow_nil => false
  property :name, String, :allow_nil => false

  has n, :users
end

class PartType
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :allow_nil => false

  has n, :photos
  has n, :cosmetics
end

PartTypes = {}
PartType.all.each{|type| PartTypes[type.name.downcase.to_sym] = type.id}

class PhotoSet
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime, :default => TimeProc, :allow_nil => false

  has n, :photos
  has n, :cosmetic_taggings
  has n, :cosmetics, :through => :cosmetic_taggings
  belongs_to :user
  belongs_to :user_level

  def user_name
    user.name
  end
  def date
    created_at.strftime("%Y/%m/%d")
  end
  def eye
    photos.find{|photo| photo.part_type_id == PartTypes[:eye]}
  end
  def cheek
    photos.find{|photo| photo.part_type_id == PartTypes[:cheek]}
  end
  def lip
    photos.find{|photo| photo.part_type_id == PartTypes[:lip]}
  end
  def face
    photos.find{|photo| photo.part_type_id == PartTypes[:face]}
  end
end

class Photo
  include DataMapper::Resource

  property :id, Serial
  property :path, String, :allow_nil => false
  property :created_at, DateTime, :default => TimeProc, :allow_nil => false

  belongs_to :photo_set
  belongs_to :part_type
  belongs_to :user

  def date
    created_at.strftime("%Y/%m/%d")
  end
end

class Brand
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :allow_nil => false

  has n, :cosmetics
end

class Color
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :allow_nil => false

  has n, :cosmetics
end

class CosmeticTagging
  include DataMapper::Resource

  belongs_to :cosmetic, :key => true
  belongs_to :photo_set, :key => true
end

class Rfid
  include DataMapper::Resource

  property :rfid, Integer, :key => true, :allow_nil => false

  belongs_to :cosmetic
end

class OwnCosmetic
  include DataMapper::Resource

  belongs_to :user, :key => true
  belongs_to :cosmetic, :key => true
end

class Cosmetic
  include DataMapper::Resource

  property :id, Serial
  property :jancode, String, :allow_nil => false
  property :name, String, :allow_nil => false
  property :url, String
  property :image, String

  has n, :cosmetic_taggings
  has n, :photo_sets, :through => :cosmetic_taggings
  has n, :rfids
  has n, :own_cosmetics
  belongs_to :part_type
  belongs_to :brand
  belongs_to :color

  def part_name
    part_type.name
  end
  def brand_name
    brand.name
  end
  def color_name
    color.name
  end
end

DataMapper.auto_upgrade!
