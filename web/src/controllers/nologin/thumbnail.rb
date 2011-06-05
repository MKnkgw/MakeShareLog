class NoLogin
  get %r{/cosme/thumb/(\d+)(?:w(\d+))?} do|id, w|
    #width = w ? w : $cosme_thumb_width
    photo = Photo.get(id.to_i)
    puts photo.content_type
    send_file photo.path, :type => photo.content_type
    #if photo then
    #  send_file photo_thumb(photo, "cosme", width)
    #end
  end

  get %r{/face/thumb/(\d+)(?:w(\d+))?} do|id, w|
    width = w ? w : $face_thumb_width
    photo = Photo.get(id.to_i)
    if photo then
      send_file photo_thumb(photo, "face", width)
    end
  end
end
