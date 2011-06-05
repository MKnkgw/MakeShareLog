class NoLogin
  def send_thumbnail(id, w)
    photo = Photo.get(id)
    thumb = Thumbnail.first(:width => w.to_i, :photo_id => id)
    unless thumb then
      thumb = create_thumbnail(photo, w)
    end
    send_file thumb.path, :type => photo.content_type
  end

  get %r{/thumb/(\d+)w(\d+)} do|id, w|
    send_thumbnail(id.to_i, w.to_i)
  end

  get %r{/thumb/face/(\d+)} do|id|
    send_thumbnail(id.to_i, $face_thumb_width)
  end

  get %r{/thumb/cosme/(\d+)} do|id|
    send_thumbnail(id.to_i, $cosme_thumb_width)
  end
end
