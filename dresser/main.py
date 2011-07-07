# encoding=utf-8

import sys
import asyncore

from rfidclient import RfidClient
from dresser_handler import DresserHandler
from cosmapper_handler import CosmapperHandler
from settings import Settings

def main(port):
  # yaml形式の設定ファイルの読み込み
  settings = Settings("settings.yaml")

  # JANCODEテーブルがなかったら初期化
  if not settings.get("jancodes"):
    settings.set("jancodes", {})

  # カメラ画面の初期化
  camera = CameraWindow(settings)
  # カメラ画面の表示
  camera.start()
  # カメラ画面の更新処理を開始
  camera.event_set("run", "start")

  # ローカルホストのRFIDサーバへport番号を指定して接続
  client = RfidClient(port)
  # RFIDサーバの信号をCosmapperHandlerに投げるよう設定
  client.add_handler(CosmapperHandler(settings, camera))
  # RFIDサーバの信号をDresserHandlerに投げるよう設定
  client.add_handler(DresserHandler(settings, camera))
  # RFIDサーバの信号の処理を開始
  asyncore.loop()

if __name__ == "__main__":
  if len(sys.argv) >= 2:
    main(int(sys.argv[1]))
  else:
    main(4321)
