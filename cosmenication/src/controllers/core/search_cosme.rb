class Core
  get "/search/cosme/:cosme_id" do
    cosme_id = params[:cosme_id].to_i
    @cosme = Cosmetic.get(cosme_id)
    face_list = []
    CosmeticTagging.all(
      :cosmetic_id => cosme_id
    ).each{|tag|
      set = tag.photo_set
      owner = User.get(set.user_id)
      user_id = session[:user_id]
      if user_id == owner.id then
        face_list.push(set.face)
      else
        guser = GroupUser.first(:owner_id => owner.id, :user_id => user_id)
        group = guser ? guser.group : owner.default_group
        part_type_id = group.any_public_part_type_id
        face_list.push(set.photo(part_type_id))
      end
    }
    @photo_list = face_list.sort_by{|face|
      # ‘‚¨‹C‚É“ü‚ç‚ê”, B‰e“ú
      [-face.user.like_count, -1*face.photo_set.created_at.to_i]
    }
    erb :search_cosme
  end
end
