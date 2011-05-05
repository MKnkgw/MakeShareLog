get "/search/cosme/:cosme_id" do
  cosme_id = params[:cosme_id].to_i
  @cosme = Cosmetic.get(cosme_id)
  @photo_list = CosmeticTagging.all(
    :cosmetic_id => cosme_id
  ).map!{|tag| tag.photo_set}.select{|set|
    user = User.get(set.user_id)
    session[:user_id] == user.id || user.public_settings.any?{|pub| pub.public}
  }.sort_by{|set|
    [-set.user_level.value, set.created_at]
  }.map{|set|
    user = User.get(set.user_id)
    if user.public?($part_types[:face]) then
      set.face
    elsif user.public?(@cosme.part_type_id) then
      set.photo(@cosme.part_type_id)
    else
      set.photo(user.public_settings.find{|pub| pub.public}.part_type_id)
    end
  }
  erb :search_cosme
end
