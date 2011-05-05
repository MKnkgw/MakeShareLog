get "/cosme/:id" do
  cosme = Cosmetic.get(params[:id].to_i)
  if cosme then
    send_file $datadir + "/" + cosme.image
  end
end
