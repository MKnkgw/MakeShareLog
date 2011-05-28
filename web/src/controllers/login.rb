class Login < Sinatra::Base
  set :sessions, true
  
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
        if session[:goto] then
          goto = session[:goto]
          session[:goto] = nil
          redirect goto
        else
          redirect "/"
        end
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
