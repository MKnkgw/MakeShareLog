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

class PhotoSet
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime, :default => TimeProc, :allow_nil => false

  has n, :photos
  has n, :cosmetic_taggings
  has n, :cosmetics, :through => :cosmetic_taggings
  belongs_to :user
  belongs_to :user_level
end

class Photo
  include DataMapper::Resource

  property :id, Serial
  property :path, String, :allow_nil => false
  property :created_at, DateTime, :default => TimeProc, :allow_nil => false

  belongs_to :photo_set
  belongs_to :part_type
  belongs_to :user

  def user_name
    User.get(user_id).name
  end
  def user_level
    UserLevel.get(PhotoSet.get(photo_set_id).user_level_id).name
  end
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
  belongs_to :part_type
  belongs_to :brand
  belongs_to :color

  def part_name
    PartType.get(part_type_id).name
  end
end

DataMapper.auto_upgrade!
