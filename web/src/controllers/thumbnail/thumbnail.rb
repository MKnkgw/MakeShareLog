class Thumbnail < Sinatra::Base
  get %r{/cosme/thumb/(\d+)(?:w(\d+))?} do|id, w|
    width = w ? w : $cosme_thumb_width
    photo = Photo.get(id.to_i)
    if photo then
      send_file photo_thumb(photo, "cosme", width)
    end
  end

  get %r{/face/thumb/(\d+)(?:w(\d+))?} do|id, w|
    width = w ? w : $face_thumb_width
    photo = Photo.get(id.to_i)
    if photo then
      send_file photo_thumb(photo, "face", width)
    end
  end
end
