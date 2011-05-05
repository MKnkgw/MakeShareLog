get "/search/cosme/:cosme_id" do
  cosme_id = params[:cosme_id].to_i
  @photo_list = CosmeticTagging.all(
    :cosmetic_id => cosme_id
  ).map{|tag| PhotoSet.get(tag.photo_set_id).face}.
    sort{|a, b| -1*(a.created_at <=> b.created_at)}.
    sort{|a, b| -1*(a.photo_set.user_level.value <=> b.photo_set.user_level.value)}
  @cosme = Cosmetic.get(cosme_id)
  erb :search_cosme
end
