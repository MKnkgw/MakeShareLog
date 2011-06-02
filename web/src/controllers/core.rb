class Login < Sinatra::Base
  set :sessions, true

  configure(:development) do
    register Sinatra::Reloader
    also_reload "app.rb"
    also_reload "controllers/login/*.rb"
  end

  Dir.glob("controllers/login/*.rb").each{|rb| load(rb) }
end

class Thumbnail < Sinatra::Base
  configure(:development) do
    register Sinatra::Reloader
    also_reload "app.rb"
    also_reload "controllers/thumbnail/*.rb"
  end

  Dir.glob("controllers/thumbnail/*.rb").each{|rb| load(rb) }
end

class MakeupCore < Sinatra::Base
  set :sessions, true
  set :public, File.dirname(File.dirname(__FILE__)) + "/public"

  configure(:development) do
    register Sinatra::Reloader
    also_reload "app.rb"
    also_reload "controllers/core/*.rb"
  end

  Dir.glob("controllers/core/*.rb").each{|rb| load(rb) }

  use Login
  use Thumbnail

  before do
    if !session[:user_name] then
      session[:goto] = request.url
      redirect "/login"
      halt
    end
  end
end
