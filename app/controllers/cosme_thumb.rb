get "/cosme/thumb/:id" do
  cosme = Cosmetic.get(params[:id].to_i)
  if cosme then
    path = $datadir + "/" + cosme.image
    send_file photo_thumb("cosme", cosme.id, path, $cosme_thumb_width)
  end
end
