class Core
  # http://host/ or http://host/index
  get "/" do
    user_id = session[:user_id]
    @photo_list = []
    @cosme_list = []
    #@photo_list = FacePhoto.all(
    #  :user_id => user_id,
    #  :part_type_id => $part_types[:face]
    #).sort_by{|face|
    #  -face.photo.created_at.to_i
    #} or []
    #@cosme_list = OwnCosmetic.all(:user_id => user_id).map{|own|
    #  own.cosmetic
    #} or []
    erb :index
  end
end
