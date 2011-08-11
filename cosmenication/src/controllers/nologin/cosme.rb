class NoLogin
  def register_cosme(jancode)
    items = JSON.parse `ruby scripts/item_info.rb #{jancode}`
    if items[0] then
      item = items[0]
    else
      item = {
        "brand" => "ブランド名",
        "name" => "化粧品名",
        "url" => "http://",
        "caption" => "説明文",
        "image" => "http://hogel.org/noimage.gif",
        "genres" => [],
      }
    end

    # register brand
    brand = Brand.first_or_create(:name => item["brand"])

    # register photo
    photo_url = item["image"]
    photo_path = "#{$photodir}/#{Photo.last_insert_id}"
    download = JSON.parse `ruby scripts/download.rb "#{photo_url}" #{photo_path}`
    photo = Photo.create(
      :path => photo_path,
      :content_type => download["content_type"]
    )

    nocolor = Color.first_or_create(:name => "")

    # register cosme
    cosme = Cosmetic.create(
      :jancode => jancode,
      :name => item["name"],
      :url => item["url"],
      :description => item["caption"] || "",
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
        :cosmetic_id => cosme.id
      )
    end

    cosme
  end

  def first_or_register(jancode)
    if cosme = Cosmetic.first(:jancode => jancode) then
      cosme
    else
      register_cosme jancode
    end
  end

  get "/cosme/edit/:jancode" do
    jancode = params[:jancode]
    @cosme = first_or_register(jancode)

    erb :cosme_edit
  end

  get "/api/cosme/edit/:jancode" do
    jancode = params[:jancode]
    cosme = first_or_register(jancode)

    content_type :json
    cosme.to_json
  end

  post "/cosme/edit/:jancode" do
    jancode = params[:jancode]
    @cosme = first_or_register(jancode)

    @cosme.name = params[:cosme_name]
    @cosme.brand_id = Brand.first_or_create(:name => params[:cosme_brand]).id
    @cosme.description = params[:cosme_description]
    @cosme.color_id = Color.first_or_create(:name => params[:cosme_color]).id
    @cosme.url = params[:cosme_url]

    @cosme.save

    erb :cosme_edit
  end
end
