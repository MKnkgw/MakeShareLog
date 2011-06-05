class NoLogin
  get "/photo/:id" do
    id = params[:id]
    photo = Photo.get(id.to_i)
    send_file photo.path, :type => photo.content_type
  end
end
