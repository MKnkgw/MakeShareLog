@start ..\RFIDTakayaServer\RFIDTakayaServer.exe

@ping localhost -n 5 > nul

@start python server.py > log\camera-server.log

@ping localhost -n 1 > nul

@start python rfidcamera.py > log\rfid-camera.log
