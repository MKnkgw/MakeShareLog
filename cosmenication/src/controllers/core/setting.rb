class Core
  get "/setting" do
    user_id = session[:user_id]
    @groups = Group.all(:user_id => user_id)
    erb :setting
  end

  post "/setting" do
    user_id = session[:user_id]
    @groups = Group.all(:user_id => user_id)
    me = User.get(user_id)
    case params[:change]
    when "password"
      pass1 = params[:pass1]
      pass2 = params[:pass2]
      if pass1 == pass2 then
        me[:pass] = Digest::MD5.hexdigest(pass1)
        me.save
        @notify = "パスワードを変更しました"
        #@error = "パスワードの変更に失敗しました"
      else
        @error = "パスワードが違います"
      end
    when "public"
      group_id = params[:group_id].to_i
      group = Group.get(group_id)
      group.name = params[:group_name]
      group.description = params[:group_description]
      group.save
      ["face", "eye", "cheek", "lip"].each do|part_name|
        publish = !!params["public_#{part_name}".to_sym]
        part_type_id = PART_TYPES[part_name.capitalize.to_sym]
        pub = PublicSetting.first(
          :group_id => group_id,
          :part_type_id => part_type_id
        )
        pub.public = publish
        pub.save
      end
      @notify = "「#{group.name}」の公開設定を変更しました"
    when "newgroup"
      name = params[:newgroup_name]
      description = params[:newgroup_description]
      group = Group.create(:user_id => user_id, :name => name, :description => description)
      group_id = group.id
      ["face", "eye", "cheek", "lip"].each do|part_name|
        publish = !!params["public_#{part_name}".to_sym]
        part_type_id = PART_TYPES[part_name.capitalize.to_sym]
        PublicSetting.create(
          :group_id => group_id,
          :part_type_id => part_type_id,
          :public => publish
        )
      end
      @notify = "新規グループ「#{name}」を作成しました"
    else
        @error = "未知の入力です"
    end
    erb :setting
  end
end
