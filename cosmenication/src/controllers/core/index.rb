class Core
  # http://host/ or http://host/index
  get "/" do
    user_id = session[:user_id]
    @photo_list = PhotoSet.all(
      :user_id => user_id
    ).sort_by{|set|
      -set.created_at.to_i
    }.map{|set|
      set.face
    } or []
    @cosme_list = UserCosmetic.all(:user_id => user_id).map{|ucosme|
      ucosme.cosmetic
    } or []
    erb :index
  end
end
