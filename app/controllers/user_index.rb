# http://host/user/MKnkgw/
get "/user/:user_name" do
  @user_name = params[:user_name]
  user = User.first(:name => @user_name)
  user_id = user.id
  @photo_list = Photo.all(
    :user_id => user_id,
    :part_type_id => PartTypes[:face]
  ).sort{|a, b| -1*(a.created_at <=> b.created_at)}
  @cosme_list = OwnCosmetic.all(:user_id => user_id).map{|own|
    Cosmetic.get(own.cosmetic_id)
  }
  erb :user_index
end
