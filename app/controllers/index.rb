# http://host/ or http://host/index
get %r{^/$|^/index$} do
  user_id = session[:user_id]
  @photo_list = Photo.all(
    :user_id => user_id,
    :part_type_id => PartType.first(:name => "Face").id
  )
  @cosme_list = OwnCosmetic.all(:user_id => user_id).map{|own|
    Cosmetic.get(own.cosmetic_id)
  }
  erb :index
end
