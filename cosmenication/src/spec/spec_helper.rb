require "app"
require "sinatra"
require "rack/test"
require "rspec"

set :environment, :test

RSpec.configure do |config|
end

#set :run, false
set :raise_errors, true
#set :logging, false

