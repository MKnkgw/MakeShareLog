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
end

class PhotoSet
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime, :default => TimeProc, :allow_nil => false

  has n, :photos
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
end

DataMapper.auto_upgrade!
