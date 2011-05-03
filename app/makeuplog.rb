require "sinatra"
require "sinatra/reloader"
require "erb"
require "digest/md5"

load "models.rb"

#set :public, File.dirname(__FILE__) + '/public'
#set :views, File.dirname(__FILE__) + '/views'
set :port, 80
set :reload, true

class Login < Sinatra::Base
  set :sessions, true
  set :reload, true
  
  get "/login" do
    erb :login
  end

  post "/login" do
    name = params[:name]
    pass = Digest::MD5.hexdigest(params[:pass])
    if name and pass then
      user = User.first(:name => name, :pass => pass)
      if user then
        session[:name] = name
        redirect "/"
      else
        @error = "ログイン失敗しました。"
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
    user = User.new(:name => name, :pass => pass)
    if user.save then
      redirect "/login"
    else
      @error = "ユーザ作成に失敗しました。"
      erb :create
    end
  end
end

use Login

before do
  if !session[:name] then
    redirect "/login"
    halt
  end
end

get "/" do
  erb :index
end

get "/*" do
  erb params[:splat][0].to_sym
end

post "/setting" do
  name = session[:name]
  pass1 = params[:pass1]
  pass2 = params[:pass2]
  if pass1 == pass2 then
    user = User.first(:name => name)
    user[:pass] = Digest::MD5.hexdigest(pass1)
    if !user.save then
      @error = "パスワードの変更に失敗しました"
    end
  else
    @error = "パスワードが違います"
  end
  erb :setting
end
