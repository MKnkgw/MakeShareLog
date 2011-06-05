class NoLogin
  get %r{/thumb/(\d+)w(\d+)} do|id, w|
    photo_id = id.to_i
    photo = Photo.get(photo_id)
    thumb = Thumbnail.first(:width => w.to_i, :photo_id => photo_id)
    unless thumb then
      thumb = create_thumbnail(photo, w)
    end
    send_file thumb.path, :type => photo.content_type
  end
end
