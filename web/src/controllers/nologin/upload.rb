class NoLogin
  def upload_photo_file(tempfile, name)
    path = "#$datadir/#{name}"
    File.open(path, "wb"){|file|
      file.write(tempfile.read)
    }
    photo = Photo.new(:path => path)

    photo.save ? photo : nil
  end

  get "/photo/upload" do
  end
end
