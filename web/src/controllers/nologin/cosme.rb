class NoLogin
  get "/cosme/edit/:jancode" do
    jancode = params[:jancode]
    unless @cosme = Cosmetic.first(:jancode => jancode) then
      items = JSON.parse `ruby scripts/item_info.rb #{jancode}`
      p items
      item = items[0] or halt("Not Found Item: #{jancode}")

      # register brand
      brand = Brand.find_or_create(:name => item["brand"])

      # register photo
      photo_url = item["image"]
      photo_path = "#{$photodir}/#{Photo.last_insert_id}"
      download = JSON.parse `ruby scripts/download.rb #{photo_url} #{photo_path}`
      photo = Photo.create(
        :path => photo_path,
        :content_type => download["content_type"]
      )

      nocolor = Color.find_or_create(:name => "")

      # register cosme
      @cosme = Cosmetic.create(
        :jancode => jancode,
        :name => item["name"],
        :url => item["url"],
        :description => item["caption"],
        :brand_id => brand.id,
        :photo_id => photo.id,
        :color_id => nocolor.id
      )

      # register genre
      genres = []
      level = 0
      item["genres"].each do|name|
        level += 1
        genres.push Genre.create(
          :name => name,
          :level => level,
          :cosmetic_id => @cosme.id
        )
      end
    end

    erb :cosme_edit
  end
end
