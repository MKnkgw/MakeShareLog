import os
import yaml

class Settings:
  def __init__(self, file):
    self.file = file

    if (os.path.isfile(file)):
      data = open(file).read()
      self.dic = yaml.load(data)
    else:
      self.dic = {}

  def save(self):
    data = yaml.dump(self.dic)
    open(self.file, "w").write(data)

  def get(self, key):
    if key in self.dic:
      return self.dic[key]

  def set(self, key, val):
    self.dic[key] = val

if __name__ == "__main__":
  settings = Settings("settings.yaml")
  print("4627: " + settings.get("jancodes")["4627"])
  settings.set("jancodes", {
    "4627": "4901872152407",
    "4639": "4901301238139",
    "4650": "4901872361786",
    "4651": "4901872152445",
    "4656": "4901872152452",
    "4667": "4901301238146",
    "4689": "4901872378975",
    "4700": "4901301238122",
    "4714": "4901872378968",
    "4719": "4901301238115",
    "4720": "4901872361564",
    "4724": "4901872152469",
  })
  settings.save()
