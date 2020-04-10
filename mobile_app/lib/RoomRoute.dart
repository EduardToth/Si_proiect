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
    await BluetoothFunctionality_SingleDevice.connect(room.bluetoothDevice);
  }

  Widget build(BuildContext context){
    new Timer(const Duration(seconds:1), (){
      try {
        setState(() {
          Uint8List msg;
          try {
            msg = BluetoothFunctionality_SingleDevice.readMessageFromBluetooth();
          }
          catch(e){
            print(e);
          }

          if(msg != null) {
            print("Room Page is reading: " + msg.toString());
            room.currentTemperature = msg.first;
          }
          else{
            print("Room Page. Not reading anything");
          }

          BluetoothFunctionality_SingleDevice.sendMessageViaBluetooth(String.fromCharCode(room.desiredTemperature));
        });
      }
      catch(Exception){
        BluetoothFunctionality_SingleDevice.disconnect();
      }


    });

    return Scaffold(
      appBar: AppBar(
        title: Text(room.roomName),
        //backgroundColor: room.IsOnAuto ? ColorIsOnAuto : ColorNotIsOnAuto
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
    double fontSize = 15;

    return Column(
      children: <Widget>[
        SwitchListTile(
          title: Text(
            "Automatic mode",
            style: TextStyle(fontSize: fontSize),
          ),
          value: room.isOnAuto,
          onChanged: (bool b) {
            _toggleAuto();
          },
        ),
        SwitchListTile(
          title: Text(
            "Heater",
            style: TextStyle(fontSize: fontSize),
          ),
          value: room.isOn,
          onChanged: (bool b) {
            _toggleOnOff();
          },
        )
      ],
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    );
  }

  Widget _buildTemperatureDisplay(){
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
            activeColor: room.isOnAuto ? _colorSliderActiveColorAuto : _colorSliderActiveColorNotAuto,
            inactiveColor: room.isOnAuto ? _colorSliderInactiveColorAuto : _colorSliderInactiveColorNotAuto,
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
      _setIsOnAuto(!room.isOnAuto);
    });
  }

  void _toggleOnOff(){
    setState(() {
      room.isOn = !room.isOn;
      _setIsOnAuto(false);
    });
  }

  void _setIsOnAuto(bool isOnAuto){
    room.isOnAuto = isOnAuto;
  }
}