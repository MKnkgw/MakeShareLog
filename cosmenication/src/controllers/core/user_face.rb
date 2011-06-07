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

    @cosmetics = @photoset.cosmetics

    face =
      if user.id == me.id then
        @photoset.face
      else
        part_type_id = user.any_public_part_type_id(me)
        @photoset.photo(part_type_id)
      end
    @photo = face.photo

    @you_like = Like.get(@photoset.id, me.id)

    @likes = @photoset.likes.size

    erb :user_face
  end
end
