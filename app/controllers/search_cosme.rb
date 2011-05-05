get "/search/cosme/:cosme_id" do
  cosme_id = params[:cosme_id].to_i
  @photo_list = CosmeticTagging.all(
    :cosmetic_id => cosme_id
  ).map{|tag| PhotoSet.get(tag.photo_set_id).face}
  @cosme = Cosmetic.get(cosme_id)
  erb :search_cosme
end
