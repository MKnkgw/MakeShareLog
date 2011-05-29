import sys, time
import pygame
import Image
import VideoCapture

WAIT_TIME = 3
FONT_SIZE = 64

def image2surface(image):
  mode = image.mode
  size = image.size
  data = image.tostring()

  return pygame.image.fromstring(data, size, mode)

class Camera:
  PREVIEW_WIDTH = 640
  PREVIEW_HEIGHT = 480
  PHOTO_WIDTH = 1600
  PHOTO_HEIGHT = 1200

  def __init__(self):
    self.preview_size = Camera.PREVIEW_WIDTH, Camera.PREVIEW_HEIGHT

    pygame.init()
    pygame.font.init()

    self.screen = pygame.display.set_mode(self.preview_size)

    pygame.display.set_caption("Camera Application")
    pygame.display.set_icon(pygame.image.load("camera.png"))

    self.ORIGIN = (0, 0)

    self.update_time = time.time()
    self.fps = 0.0

    self.camera = VideoCapture.Device()
    self.camera.setResolution(Camera.PHOTO_WIDTH, Camera.PHOTO_HEIGHT)

    fontname = pygame.font.get_default_font()
    self.font = pygame.font.Font(fontname, FONT_SIZE)

  def retrieve(self):
    image = self.camera.getImage()
    if image:
      if (image.size == self.preview_size):
        return image2surface(image)
      newimage = image.resize(self.preview_size)
      return image2surface(newimage)

  def event(self):
    return pygame.event.get()

  def update(self, str=None):
    surface = self.retrieve()
    
    self.screen.blit(surface, self.ORIGIN)
    if str:
      text = self.font.render(str, False, (255, 255, 255))
      x = (Camera.PREVIEW_WIDTH - text.get_width()) / 2
      y = (Camera.PREVIEW_HEIGHT - text.get_height()) / 2
      self.screen.blit(text, (x, y))
    pygame.display.flip()

    now = time.time()
    self.fps = 1 / (now - self.update_time)
    self.update_time = now

    return pygame.event.get()

  def save(self, path):
    start = time.time()
    while True:
      pygame.event.get()
      t = time.time()
      diff = t - start
      if diff > WAIT_TIME:
        break
      self.update(str(int(0.99 + WAIT_TIME - diff)))

    self.update()
    self.camera.saveSnapshot(path)
    print("saved: %s" % path)

if __name__ == "__main__":
  camera = Camera()
  while True:
    for event in pygame.event.get():
      if event.type == pygame.QUIT:
        sys.exit()
      elif event.type == pygame.KEYDOWN:
        if (event.key == pygame.K_p):
          camera.save("photo.jpg")
    camera.update()
    print("fps: %.2f" % camera.fps)

# vim: sw=2 ts=2 et:
