import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Room{
  int id = -1;
  String roomName = "Unnamed";
  BluetoothDevice bluetoothDevice;

  int desiredTemperature = -100;
  int currentTemperature = -100;
  static const int minDesiredTemperature = 15;
  static const int maxDesiredTemperature = 35;

  bool isOnAuto = false;
  bool isOn = false;

  Room(int id, String roomName, int desiredTemperature, bool isOnAuto){
    this.id = id;
    this.roomName = roomName;
    this.isOnAuto = isOnAuto;

    if(desiredTemperature < minDesiredTemperature){
      this.desiredTemperature = minDesiredTemperature;
    }else if(desiredTemperature > maxDesiredTemperature){
      this.desiredTemperature = maxDesiredTemperature;
    }else{
      this.desiredTemperature = desiredTemperature;
    }
  }
}