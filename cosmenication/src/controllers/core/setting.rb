class Core
  get "/setting" do
    erb :setting
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
end
