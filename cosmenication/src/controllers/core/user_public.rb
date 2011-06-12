class Core
  def show_user_public(me, user)
    @groups = Group.all(:user_id => me.id)
    @user_group_id = me.users_group(user).id
    erb :user_public
  end

  get "/user/public/:user_name" do
    me = User.get(session[:user_id])
    @user_name = params[:user_name]
    user = User.first(:name => @user_name)
    show_user_public(me, user)
  end
  
  post "/user/public/:user_name" do
    group_id = params[:group_id].to_i

    @user_name = params[:user_name]
    user = User.first(:name => @user_name)
    me = User.get(session[:user_id])
    if guser = GroupUser.first(:owner_id => me.id, :user_id => user.id) then
      guser.group_id = group_id
      guser.save
    else
      group = GroupUser.create(
        :owner_id => me.id,
        :user_id => user.id,
        :group_id => group_id
      )
    end

    redirect "/user/#{@user_name}"
  end
end
