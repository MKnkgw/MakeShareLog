get "/face/:photoset_id" do
  @photoset = PhotoSet.get(params[:photoset_id].to_i)
  @photos = @photoset.photos.sort{|a, b| a.part_type_id <=> b.part_type_id }
  @cosmetics = @photoset.cosmetics
  erb :face
end
