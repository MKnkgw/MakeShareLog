class Core
  get "/user/face/:photoset_id" do
    @photoset = PhotoSet.get(params[:photoset_id].to_i)
    user = @photoset.user

    me = User.get(session[:user_id])

    @photos = @photoset.face_photos.select{|face|
      if user.id == me.id then
        true
      else
        user.public?(me, face.part_type_id)
      end
    }.sort_by{|face| face.part_type_id }

    @cosme_have_list = []
    @cosme_have_not_list = []
    @photoset.cosmetics.each{|cosmetic|
      if UserCosmetic.get(me.id, cosmetic.id) then
        @cosme_have_list.push(cosmetic)
      else
        @cosme_have_not_list.push(cosmetic)
      end
    }

    face =
      if user.id == me.id then
        @photoset.face
      else
        part_type_id = user.any_public_part_type_id(me)
        @photoset.photo(part_type_id)
      end
    @photo = face.photo

    @you_like = Like.get(me.id, @photoset.id)

    @likes = @photoset.likes.size

    erb :user_face
  end
end
