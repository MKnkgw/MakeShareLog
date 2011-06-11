class Core
  # http://host/user/MKnkgw/
  get "/user/:user_name" do
    me = User.get(session[:user_id])
    @user_name = params[:user_name]
    owner = User.first(:name => @user_name)
    face_list = []
    owner.photo_sets.each{|set|
      if me.id == owner.id then
        face_list.push(set.face)
      else
        if part_type_id = owner.any_public_part_type_id(me) then
          face_list.push(set.photo(part_type_id))
        end
      end
    }
    @photo_list = face_list.sort_by{|face|
      -face.photo.created_at.to_i
    }
    @cosme_have_list = []
    @cosme_have_not_list = []
    UserCosmetic.all(:user_id => owner.id).map{|users|
      cosmetic = users.cosmetic
      if UserCosmetic.get(me.id, cosmetic.id) then
        @cosme_have_list.push(cosmetic)
      else
        @cosme_have_not_list.push(cosmetic)
      end
    }
    erb :user_index
  end
end
