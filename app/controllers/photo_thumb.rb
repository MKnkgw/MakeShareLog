def create_thumb(src, dst, width)
  system("#$convert -resize #{width}x #{src} #{dst}")
end

def photo_thumb(id, path, prefix, width)
  ext = File.extname(path)
  thumb_path = "#$thumbdir/#{prefix}-#{id}-#{width}-thumb#{ext}"
  if !File.exist?(thumb_path) || File.mtime(thumb_path) < File.mtime(path) then
    create_thumb(path, thumb_path, width)
  end
  thumb_path
end

class Thumbnail < Sinatra::Base
  get %r{/photo/thumb/(\d+)(?:w(\d+))?} do|id, w|
    photo = Photo.get(id.to_i)
    width = w ? w : $face_thumb_width
    if photo then
      path = $datadir + "/" + photo.path
      send_file photo_thumb(photo.id, path, "photo", width)
    end
  end

  get %r{/cosme/thumb/(\d+)(?:w(\d+))?} do|id, w|
    cosme = Cosmetic.get(id.to_i)
    width = w ? w : $cosme_thumb_width
    if cosme then
      path = $datadir + "/" + cosme.image
      p photo_thumb(cosme.id, path, "cosme", width)
      send_file photo_thumb(cosme.id, path, "cosme", width)
    end
  end
end
