class CosmeEdit < Sinatra::Base
  get "/cosme/new/:jancode" do
    @jancode = params[:jancode]
    erb :cosme_new
  end

  get "/cosme/edit/:jancode" do
    session[:cosme_edit_before] = request.referer
    @cosme = Cosmetic.first(:jancode => params[:jancode])
    erb :cosme_edit
  end
  
  post "/cosme/edit/:jancode" do
    photo_file = params[:cosme_photo_file]
    name = params[:cosme_name]
    brand = params[:cosme_brand]
    part = params[:cosme_part].to_i
    color = params[:cosme_color]
    url = params[:cosme_url]
    jancode = params[:jancode]

    data = {
      :name => name,
      :brand_id => find_or_create(Brand, :name => brand).id,
      :part_type_id => part,
      :color_id => find_or_create(Color, :name => color).id,
      :url => url,
    }

    if photo_file then
      new_id = Photo.last_insert_id + 1
      name = "cosme_photo/cosme-upload-#{new_id}-#{photo_file[:filename]}"
      photo = upload_photo_file(photo_file[:tempfile], name)
      data[:photo_id] = photo.id
    end

    if @cosme = Cosmetic.first(:jancode => params[:jancode]) then
      @cosme.update(data)
    else
      @cosme = Cosmetic.create(data)
    end

    if session[:user_name] && session[:cosme_edit_before] then
      redirect session[:cosme_edit_before]
    else
      erb :cosme_edit
    end
  end
end
