class Core
  get "/like/:photoset_id" do
    me = User.get(session[:user_id])
    photo_set_id = params[:photoset_id].to_i
    photo_set = PhotoSet.get(photo_set_id)
    owner = photo_set.user
    like = Like.create(:owner_id => owner.id,
                    :user_id => me.id,
                    :photo_set_id => photo_set_id)
    owner.like_count += 1
    owner.save
    photo_set_id.to_s
  end

  get "/unlike/:photoset_id" do
    me = User.get(session[:user_id])
    photo_set_id = params[:photoset_id].to_i
    photo_set = PhotoSet.get(photo_set_id)
    owner = photo_set.user
    like = Like.get(me.id, photo_set_id)
    if like then
      like.destroy
      owner.like_count -= 1
      owner.save
      photo_set_id.to_s
    end
  end
end
