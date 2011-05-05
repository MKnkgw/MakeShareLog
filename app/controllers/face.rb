get "/face/:photoset_id" do
  @photoset = PhotoSet.get(params[:photoset_id].to_i)
  user = @photoset.user

  me = User.get(session[:user_id])

  @photos = @photoset.photos.select{|photo|
    user.id == me.id || user.public?(photo.part_type_id)
  }.sort_by{|photo| photo.part_type_id }

  @cosmetics = @photoset.cosmetics

  @photo = if user.id == me.id || user.public?($part_types[:face]) then
    @photoset.face
  else
    @photoset.photo(user.public_settings.find{|pub| pub.public}.part_type_id)
  end

  @you_like = Like.get(@photoset.id, me.id)
  p @you_like
  @likes = @photoset.likes.size

  erb :face
end
