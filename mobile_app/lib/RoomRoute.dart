import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'Room.dart';
import 'dart:async';

import 'BluetoothFunctionality_SingleDevice.dart';

class RoomRoute extends StatefulWidget{
  Room room;
  _RoomRouteState state;

  RoomRoute(Room room){
    this.room = room;
  }

  _RoomRouteState createState() {
    state = _RoomRouteState(room);
    return state;
  }
}

class _RoomRouteState extends State<RoomRoute>{
  Room room;
  
  Color _colorSliderActiveColorAuto = Colors.blue;
  Color _colorSliderInactiveColorAuto = Colors.lightBlueAccent;
  Color _colorSliderActiveColorNotAuto = Colors.blueGrey;
  Color _colorSliderInactiveColorNotAuto = Colors.grey;

  _RoomRouteState(Room room){
    this.room = room;
    func();
  }

  Future func() async{
    // when opening the individual room's view it first connects to the room's bluetooth device
    await BluetoothFunctionality_SingleDevice.connect(room.bluetoothDevice);
  }

  Widget build(BuildContext context){
    // every second it reads the current room temperature from bluetooth and sends the desired temperature back
    new Timer(const Duration(seconds:1), (){
      try {
        setState(() {
          Uint8List msg;
          try {
            // read the current room temperatre
            msg = BluetoothFunctionality_SingleDevice.readMessageFromBluetooth();
          }
          catch(e){
            print(e);
          }

          if(msg != null) {
            room.currentTemperature = msg.first;
          }
          else{

          }

          // the format of the sent byte is:
          // 6 LSB are the actual desired temperature
          // byte 7 is a toggle between the mobile app and the on board potentiometer
          int temp = room.desiredTemperature;
          if(room.remote){
            temp += 64;
          }
          // send the desired temperature
          BluetoothFunctionality_SingleDevice.sendMessageViaBluetooth(String.fromCharCode(temp));
        });
      }
      catch(Exception){
        // when exiting the individual room's view in the GUI
        // the timer automatically raises an exception
        // and that is how we know when to disconnect from bluetooth
        BluetoothFunctionality_SingleDevice.disconnect();
      }


    });

    // the actual GUI builder is here
    return Scaffold(
      appBar: AppBar(
        title: Text(room.roomName),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            _buildButtons(),
            _buildTemperatureDisplay(),
            _buildDesiredTemperatureSelector()
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
        padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
      ),
    );
  }

  Widget _buildButtons(){
    // toggle between the mobile app and the on board potentiometer
    // found on the top of the GUI
    double fontSize = 15;

    return Column(
      children: <Widget>[
        SwitchListTile(
          title: Text(
            "Remote control",
            style: TextStyle(fontSize: fontSize),
          ),
          value: room.remote,
          onChanged: (bool b) {
            _toggleAuto();
          },
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    );
  }

  Widget _buildTemperatureDisplay(){
    // display of the current room temperature
    // found in the middle of the GUI
    return Column(
      children: <Widget>[
        Text(
            "Current Temparature",
          style: TextStyle(fontSize: 30),
        ),
        Text(
          room.currentTemperature.toString(),
          style: TextStyle(fontSize: 50),
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }

  Widget _buildDesiredTemperatureSelector(){
    // slider used for setting the desired room temperature
    // found on the bottom of the GUI
    return Column(
      children: <Widget>[
        Text(
          "Desired Temparature",
          style: TextStyle(fontSize: 15),
        ),
        Text(
          room.desiredTemperature.toString(),
          style: TextStyle(fontSize: 20),
        ),
        SliderTheme(
          child: Slider(
            min: Room.minDesiredTemperature.toDouble(),
            max: Room.maxDesiredTemperature.toDouble(),
            value: room.desiredTemperature.toDouble(),
            onChanged: (value) {
              _setIsOnAuto(true);

              room.desiredTemperature = value.toInt();
            },
            activeColor: room.remote ? _colorSliderActiveColorAuto : _colorSliderActiveColorNotAuto,
            inactiveColor: room.remote ? _colorSliderInactiveColorAuto : _colorSliderInactiveColorNotAuto,
          ),
          data: SliderThemeData(
            showValueIndicator: ShowValueIndicator.always
          ),
        )
      ],
    );
  }

  void _toggleAuto(){
    setState(() {
      _setIsOnAuto(!room.remote);
    });
  }

  void _setIsOnAuto(bool remote){
    room.remote = remote;
  }
}