class MakeupBase < Sinatra::Base
  def self.controller_path
    "controllers/#{self.to_s.downcase}/*.rb"
  end
  def self.configure_default
    configure(:development) do
      register Sinatra::Reloader
      also_reload "app.rb"
      also_reload controller_path
    end

    Dir.glob(controller_path).each{|rb|
      load(rb)
    }
  end
end

class Login < MakeupBase
  set :sessions, true

  configure_default
end

class NoLogin < MakeupBase
  configure_default
end

class Core < MakeupBase
  set :sessions, true
  set :public, File.dirname(File.dirname(__FILE__)) + "/public"

  configure_default

  use Login
  use NoLogin

  before do
    if !session[:user_name] then
      session[:goto] = request.url
      redirect "/login"
      halt
    end
  end
end
