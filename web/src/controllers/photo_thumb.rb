class Thumbnail < Sinatra::Base
  configure(:development) do
    register Sinatra::Reloader
    also_reload "app.rb"
  end

  get %r{/face/thumb/(\d+)(?:w(\d+))?} do|id, w|
    width = w ? w : $face_thumb_width
    photo = Photo.get(id.to_i)
    if photo then
      send_file photo_thumb(photo, "face", width)
    end
  end

  get %r{/cosme/thumb/(\d+)(?:w(\d+))?} do|id, w|
    width = w ? w : $cosme_thumb_width
    photo = Photo.get(id.to_i)
    if photo then
      send_file photo_thumb(photo, "cosme", width)
    end
  end
end
