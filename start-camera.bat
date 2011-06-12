@start RFIDTakayaServer\RFIDTakayaServer.exe
@cd dresser
@start python server.py > log\camera-server.log
@sleep 1
@start python rfidcamera.py > log\rfid-camera.log
