class Core
  # http://host/user/MKnkgw/
  get "/user/:user_name" do
    @user_name = params[:user_name]
    user = User.first(:name => @user_name)
    user_id = user.id
    @photo_list = FacePhoto.all(
      :user_id => user_id,
      :part_type_id => $part_types[:face]
    ).sort_by{|face|
      -face.photo.created_at.to_i
    }
    @cosme_list = OwnCosmetic.all(:user_id => user_id).map{|own|
      Cosmetic.get(own.cosmetic_id)
    }
    erb :user_index
  end
end
