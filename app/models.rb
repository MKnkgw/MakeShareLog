require "dm-core"
require "dm-migrations"
require "dm-validations"

DataMapper.setup(:default, {
  :adapter => "sqlite",
  :database => File.expand_path("development.db")
})

class User
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :pass, String
  property :created_at, DateTime
end

DataMapper.auto_upgrade!
