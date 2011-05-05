get "/photo/thumb/:id" do
  photo = Photo.get(params[:id].to_i)
  if photo then
    path = $datadir + "/" + photo.path
    send_file photo_thumb("photo", photo.id, path, $face_thumb_width)
  end
end
