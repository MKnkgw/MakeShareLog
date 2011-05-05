get "/face/:photoset_id" do
  @photoset = PhotoSet.get(params[:photoset_id].to_i)
  user = @photoset.user
 
  @photos = @photoset.photos.select{|photo|
    user.public?(photo.part_type_id)
  }.sort_by{|photo| photo.part_type_id }

  @cosmetics = @photoset.cosmetics

  @photo = if user.public?($part_types[:face]) then
    @photoset.face
  else
    @photoset.photo(user.public_settings.find{|pub| pub.public}.part_type_id)
  end

  erb :face
end
