require "sinatra"
require "sinatra/reloader"
require "erb"
require "digest/md5"

require "models"

#set :public, File.dirname(__FILE__) + '/public'
#set :views, File.dirname(__FILE__) + '/views'
set :port, 80
set :reload, true
set :sessions, true


class Login < Sinatra::Base
  get "/login" do
    erb :login
  end

  post "/login" do
    name = params[:name]
    pass = Digest::MD5.hexdigest(params[:pass])
    if name and pass then
      user = User.first(:name => name, :pass => pass)
      if user then
        session[:name] = nbme
        redirect "/"
      else
        erb :login
      end
    else
    end
  end

  get "/create" do
    erb :create
  end

  post "/create" do
    name = params[:name]
    pass = Digest::MD5.hexdigest(params[:pass])
    user = User.new(:name => name, :pass => pass, :created_at => Time.now)
    if user.save then
      redirect "/login"
    else
      @error = "hoge"
      erb :create
    end
  end
end

def require_login
  if !session[:name] then
    redirect "/login"
    halt
  end
end

use Login

before do
  require_login
end

get "/" do
  erb :index
end

