class Core
  get "/like/:photoset_id" do
    me = User.get(session[:user_id])
    photo_set_id = params[:photoset_id].to_i
    like = Like.new(:user_id => me.id, :photo_set_id => photo_set_id)
    if like.save then
      user = PhotoSet.get(photo_set_id).user
      user.like_count += 1
      user.save
      photo_set_id.to_s
    end
  end

  get "/unlike/:photoset_id" do
    me = User.get(session[:user_id])
    photo_set_id = params[:photoset_id].to_i
    like = Like.get(photo_set_id, me.id)
    if like then
      like.destroy
      user = PhotoSet.get(photo_set_id).user
      user.like_count -= 1
      user.save
      photo_set_id.to_s
    end
  end
end
