require "sinatra"
require "sinatra/reloader"
require "erb"
require "digest/md5"

load "models.rb"

load "conf.rb"

def create_thumb(src, dst, width)
  system("#$convert -resize #{width}x #{src} #{dst}")
end

def photo_thumb(prefix, id, photo_path, width)
  ext = File.extname(photo_path)
  thumb_path = "#$thumbdir/#{prefix}-#{id}-#{width}-thumb#{ext}"
  if !File.exist?(thumb_path) then
    create_thumb(photo_path, thumb_path, width)
  end
  thumb_path
end

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
        session[:user_name] = name
        session[:user_id] = user.id
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
  if !session[:user_name] then
    redirect "/login"
    halt
  end
end

get "/" do
  user_id = session[:user_id]
  @photo_list = Photo.all(
    :user_id => user_id,
    :part_type_id => PartType.first(:name => "Face").id
  )
  @cosme_list = OwnCosmetic.all(:user_id => user_id).map{|own| Cosmetic.get(own.cosmetic_id)}
  erb :index
end

get "/photo/:id" do
  photo = Photo.get(params[:id].to_i)
  if photo then
    send_file $datadir + "/" + photo.path
  end
end

get "/photo/thumb/:id" do
  photo = Photo.get(params[:id].to_i)
  if photo then
    path = $datadir + "/" + photo.path
    send_file photo_thumb("photo", photo.id, path, $face_thumb_width)
  end
end

get "/cosme/:id" do
  cosme = Cosmetic.get(params[:id].to_i)
  if cosme then
    send_file $datadir + "/" + cosme.image
  end
end

get "/cosme/thumb/:id" do
  cosme = Cosmetic.get(params[:id].to_i)
  if cosme then
    path = $datadir + "/" + cosme.image
    send_file photo_thumb("cosme", cosme.id, path, $cosme_thumb_width)
  end
end

get "/*" do
  erb params[:splat][0].to_sym
end

post "/setting" do
  name = session[:user_name]
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
