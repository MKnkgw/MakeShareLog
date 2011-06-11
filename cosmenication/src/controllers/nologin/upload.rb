class NoLogin
  def create_face(me, photo_set, path, part_type_id)
    photo = Photo.create(:path => path, :content_type => "image/jpeg")
    FacePhoto.create(
      :photo_id => photo.id,
      :photo_set_id => photo_set.id,
      :part_type_id => part_type_id,
      :user_id => me.id
    )
  end

  get "/photo/upload/:name" do
    <<'EOM'
<html>
<body>
<form action="" method="POST" enctype="multipart/form-data" >
<input type="file" name="photo_file" />
<input type="text" name="jancode1" />
<input type="text" name="jancode2" />
<input type="text" name="jancode3" />
<input type="submit" />
</form>
</body>
</html>
EOM
  end

  post "/photo/upload/:name" do
    cosme1 = Cosmetic.first(:jancode => params[:jancode1])
    cosme2 = Cosmetic.first(:jancode => params[:jancode2])
    cosme3 = Cosmetic.first(:jancode => params[:jancode3])
    me = User.first(:name => params[:name]) or halt
    photo_file = params[:photo_file]

    now = Time.now
    photo_prefix = "#$photodir/#{me.name}-#{now.strftime "%Y%m%d"}"
    face_path = "#{photo_prefix}-face.jpg"
    eye_path = "#{photo_prefix}-eye.jpg"
    cheek_path = "#{photo_prefix}-cheek.jpg"
    lip_path = "#{photo_prefix}-lip.jpg"
    File.open(face_path, "wb"){|out|
      out.write photo_file[:tempfile].read
    }

    $facedetector_command_prefix = "python ../../facedetector"
    $split_eye = "#$facedetector_command_prefix/split_eye.py"
    $split_cheek = "#$facedetector_command_prefix/split_cheek.py"
    $split_mouth = "#$facedetector_command_prefix/split_mouth.py"

    STDERR.puts `#$split_eye #{face_path} #{eye_path}`
    STDERR.puts `#$split_cheek #{face_path} #{cheek_path}`
    STDERR.puts `#$split_mouth #{face_path} #{lip_path}`

    midnight = Time.local(now.year, now.month, now.day)
    if photo_set = PhotoSet.last(:user_id => me.id, :created_at.gte => midnight) then
      photo_set.face.photo.thumbnails.destroy
      photo_set.eye.photo.thumbnails.destroy
      photo_set.cheek.photo.thumbnails.destroy
      photo_set.lip.photo.thumbnails.destroy
    else
      photo_set = PhotoSet.create(:user_id => me.id)
      create_face(me, photo_set, face_path, PART_TYPES[:Face])
      create_face(me, photo_set, eye_path, PART_TYPES[:Eye])
      create_face(me, photo_set, cheek_path, PART_TYPES[:Cheek])
      create_face(me, photo_set, lip_path, PART_TYPES[:Lip])
    end

    CosmeticTagging.all(:photo_set_id => photo_set.id).destroy
    CosmeticTagging.create(:photo_set_id => photo_set.id, :cosmetic_id => cosme1.id)
    CosmeticTagging.create(:photo_set_id => photo_set.id, :cosmetic_id => cosme2.id)
    CosmeticTagging.create(:photo_set_id => photo_set.id, :cosmetic_id => cosme3.id)
    <<"EOM"
<html>
<body>
<img src="/photo/#{photo_set.face.photo.id}">
<img src="/photo/#{photo_set.eye.photo.id}">
<img src="/photo/#{photo_set.cheek.photo.id}">
<img src="/photo/#{photo_set.lip.photo.id}">
<img src="/photo/#{photo_set.lip.photo.id}">
<img src="/photo/#{cosme1.photo.id}">
<img src="/photo/#{cosme2.photo.id}">
<img src="/photo/#{cosme3.photo.id}">
</body>
</html>
EOM
  end
end
