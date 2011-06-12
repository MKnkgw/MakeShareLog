@start ..\RFIDTakayaServer\RFIDTakayaServer.exe
@sleep 1
@start python server.py > log\camera-server.log
@sleep 1
@start python rfidcamera.py > log\rfid-camera.log
