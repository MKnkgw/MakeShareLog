require "dm-core"
require "dm-migrations"
require "dm-types"
#require "dm-validations"

DataMapper.setup(:default, {
  :adapter => "sqlite",
  :database => File.expand_path("development.db")
})

DataMapper::Model.raise_on_save_failure = true

TimeProc = proc{|r, p| Time.now }

module DMUtil
  def find_or_create(args)
    first(args) || create(args)
  end
  def last_insert_id
    last_record = last
    if last_record then
      last_record.id
    else
      0
    end
  end
end

class User
  include DataMapper::Resource
  extend DMUtil

  property :id, Serial
  property :name, String, :allow_nil => false
  property :pass, String, :allow_nil => false
  property :admin, Boolean, :allow_nil => false, :default => false
  property :created_at, Time, :allow_nil => false, :default => TimeProc
  property :like_count, Integer, :allow_nil => false, :default => 0

  has n, :photo_sets
  has n, :user_cosmetics
  has n, :public_settings

  def public?(part_type_id)
    PublicSetting.first(
      :user_id => id,
      :part_type_id => part_type_id,
      :public => true
    )
  end
end

class PublicSetting
  include DataMapper::Resource
  extend DMUtil

  property :id, Serial
  property :public, Boolean

  belongs_to :user
  belongs_to :part_type
end

class PartType
  include DataMapper::Resource
  extend DMUtil

  property :id, Serial
  property :name, String, :allow_nil => false

  has n, :face_photos
  has n, :public_settings
end

class PhotoSet
  include DataMapper::Resource
  extend DMUtil

  property :id, Serial
  property :created_at, Time, :default => TimeProc, :allow_nil => false

  has n, :face_photos
  has n, :cosmetic_taggings
  has n, :cosmetics, :through => :cosmetic_taggings
  has n, :likes
  belongs_to :user

  def date
    created_at.strftime("%Y/%m/%d")
  end
  def photo(part_type_id)
    FacePhoto.first(:photo_set_id => id, :part_type_id => part_type_id)
  end
  def eye
    photo(PART_TYPES[:Eye])
  end
  def cheek
    photo(PART_TYPES[:Cheek])
  end
  def lip
    photo(PART_TYPES[:Lip])
  end
  def face
    photo(PART_TYPES[:Face])
  end
end

class Photo
  include DataMapper::Resource
  extend DMUtil

  property :id, Serial
  property :path, String, :allow_nil => false
  property :created_at, Time, :default => TimeProc, :allow_nil => false
  property :content_type, String
end

class FacePhoto
  include DataMapper::Resource
  extend DMUtil

  property :id, Serial

  belongs_to :photo
  belongs_to :photo_set
  belongs_to :part_type
  belongs_to :user
end

class Brand
  include DataMapper::Resource
  extend DMUtil

  property :id, Serial
  property :name, String, :allow_nil => false

  has n, :cosmetics
end

class Color
  include DataMapper::Resource
  extend DMUtil

  property :id, Serial
  property :name, String, :allow_nil => false

  has n, :cosmetics
end

class CosmeticTagging
  include DataMapper::Resource
  extend DMUtil

  belongs_to :cosmetic, :key => true
  belongs_to :photo_set, :key => true
end

class UserCosmetic
  include DataMapper::Resource
  extend DMUtil

  belongs_to :user, :key => true
  belongs_to :cosmetic, :key => true
end

class Cosmetic
  include DataMapper::Resource
  extend DMUtil

  property :id, Serial
  property :jancode, String, :allow_nil => false, :unique => true
  property :name, String, :allow_nil => false
  property :url, String
  property :description, String

  has n, :cosmetic_taggings
  has n, :photo_sets, :through => :cosmetic_taggings
  has n, :user_cosmetics
  has n, :genres
  belongs_to :brand
  belongs_to :color
  belongs_to :photo
end

class Genre
  include DataMapper::Resource
  extend DMUtil

  property :id, Serial
  property :name, String, :allow_nil => false
  property :level, Integer, :allow_nil => false

  belongs_to :cosmetic, :key => true
end

class Like
  include DataMapper::Resource
  extend DMUtil

  belongs_to :user, :key => true
  belongs_to :photo_set, :key => true
end

DataMapper.auto_upgrade!

class PhotoSet
  PART_TYPES = {}
  ["Eye", "Cheek", "Lip", "Face"].each do|name|
    unless PartType.first(:name => name) then
      part = PartType.create(:name => name)
      PART_TYPES[name.to_sym] = part.id
    end
  end
end
