# http://host/ or http://host/index
get %r{^/$|^/index$} do
  user_id = session[:user_id]
  @photo_list = Photo.all(
    :user_id => user_id,
    :part_type_id => $part_types[:face]
  ).sort!{|a, b|
    b.created_at <=> a.created_at
  }
  @cosme_list = OwnCosmetic.all(:user_id => user_id).map{|own|
    own.cosmetic
  }
  erb :index
end
