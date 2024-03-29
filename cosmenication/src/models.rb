require "dm-core"
require "dm-migrations"
require "dm-types"
require "dm-serializer"
#require "dm-validations"

DataMapper.setup(:default, {
  :adapter => "sqlite",
  :database => File.expand_path("development.db")
})

DataMapper::Model.raise_on_save_failure = true

TimeProc = proc{|r, p| Time.now }

PART_TYPES = {}

module DMUtil
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
  has n, :groups
  has n, :owner_group_users, 'GroupUser', :childkey => :owner
  has n, :likes, 'Like', :childkey => :owner
  has n, :group_users

  def users_group(user)
    group_user = GroupUser.first(
      :owner_id => id,
      :user_id => user.id
    )
    group = group_user ? group_user.group : default_group
  end

  def public?(user, part_type_id)
    group = users_group(user)
    PublicSetting.first(
      :group_id => group.id,
      :part_type_id => part_type_id,
      :public => true
    )
  end

  def any_public_part_type_id(user)
    group = users_group(user)
    group.any_public_part_type_id
  end

  def default_group
    Group.first(:user_id => id, :forall => true)
  end
end

class Group
  include DataMapper::Resource
  extend DMUtil

  property :id, Serial
  property :name, String, :allow_nil => false
  property :description, String, :allow_nil => false
  property :forall, Boolean, :allow_nil => false, :default => false

  belongs_to :user

  has n, :group_users
  has n, :public_settings

  def any_public_part_type_id
    [:Face, :Eye, :Cheek, :Lip].each do |part|
      part_id = PART_TYPES[part]
      pub = PublicSetting.first(:group_id => id, :public => true, :part_type_id => part_id)
      if pub then
        return part_id
      end
    end
    false
  end
  def public?(part_type_id)
    PublicSetting.first(
      :group_id => id,
      :part_type_id => part_type_id,
      :public => true
    )
  end
  def eye
    public?(PART_TYPES[:Eye])
  end
  def cheek
    public?(PART_TYPES[:Cheek])
  end
  def lip
    public?(PART_TYPES[:Lip])
  end
  def face
    public?(PART_TYPES[:Face])
  end
end

class GroupUser
  include DataMapper::Resource
  extend DMUtil

  property :id, Serial

  belongs_to :owner, 'User'
  belongs_to :group
  belongs_to :user
end

class PublicSetting
  include DataMapper::Resource
  extend DMUtil

  property :id, Serial
  property :public, Boolean

  belongs_to :group
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

  has n, :thumbnails
end

class Thumbnail
  include DataMapper::Resource
  extend DMUtil

  property :id, Serial
  property :path, String, :allow_nil => false
  property :width, Integer, :allow_nil => false

  belongs_to :photo
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

  belongs_to :owner, 'User'
  belongs_to :user, :key => true
  belongs_to :photo_set, :key => true
end

DataMapper.auto_upgrade!

["Eye", "Cheek", "Lip", "Face"].each do|name|
  part = PartType.first_or_create(:name => name)
  PART_TYPES[name.to_sym] = part.id
end
