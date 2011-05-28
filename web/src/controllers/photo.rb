get "/face/:id" do
  photo = Photo.get(params[:id].to_i)
  if photo then
    send_file $datadir + "/" + photo.path
  end
end

get "/cosme/:id" do
  photo = Photo.get(params[:id].to_i)
  if photo then
    send_file $datadir + "/" + photo.path
  end
end
