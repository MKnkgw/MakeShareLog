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
  property :created_at, Time, :default => TimeProc, :allow_nil => false

  has n, :photo_sets
  has n, :own_cosmetics
  has n, :public_settings
  belongs_to :user_level

  def public?(part_type_id)
    PublicSetting.first(
      :user_id => id,
      :part_type_id => part_type_id,
      :public => true
    )
  end
end

class UserLevel
  include DataMapper::Resource

  property :id, Serial
  property :value, Integer, :allow_nil => false
  property :name, String, :allow_nil => false

  has n, :users
end

class PublicSetting
  include DataMapper::Resource

  property :id, Serial
  property :public, Boolean

  belongs_to :user
  belongs_to :part_type
end

class PartType
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :allow_nil => false

  has n, :photos
  has n, :cosmetics
  has n, :public_settings
end

class PhotoSet
  include DataMapper::Resource

  property :id, Serial
  property :created_at, Time, :default => TimeProc, :allow_nil => false

  has n, :photos
  has n, :cosmetic_taggings
  has n, :cosmetics, :through => :cosmetic_taggings
  has n, :likes
  belongs_to :user
  belongs_to :user_level

  def date
    created_at.strftime("%Y/%m/%d")
  end
  def photo(part_type_id)
    Photo.first(:photo_set_id => id, :part_type_id => part_type_id)
  end
  def eye
    photo($part_types[:eye])
  end
  def cheek
    photo($part_types[:cheek])
  end
  def lip
    photo($part_types[:lip])
  end
  def face
    photo($part_types[:face])
  end
end

class Photo
  include DataMapper::Resource

  property :id, Serial
  property :path, String, :allow_nil => false
  property :created_at, Time, :default => TimeProc, :allow_nil => false

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
  property :jancode, String, :allow_nil => false, :unique => true
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
end

class Like
  include DataMapper::Resource

  belongs_to :user, :key => true
  belongs_to :photo_set, :key => true
end

DataMapper.auto_upgrade!

$part_types = {}
PartType.all.each{|type| $part_types[type.name.downcase.to_sym] = type.id}

def find_or_create(klass, args)
  klass.first(args) || klass.create(args)
end
