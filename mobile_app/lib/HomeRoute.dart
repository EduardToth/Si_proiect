import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'BluetoothFunctionality_SingleDevice.dart';
import 'main.dart';
import 'RoomRoute.dart';
import 'Room.dart';
import 'dart:async';

class HomeRoute extends StatefulWidget{
  List<Room> rooms;
  _HomeRouteState state;

  HomeRoute(List<Room> rooms){
    this.rooms = rooms;
  }

  _HomeRouteState createState() {
    state = _HomeRouteState(rooms);
    return state;
  }
}

class _HomeRouteState extends State<HomeRoute>{
  static BuildContext _context;

  List<Room> rooms = new List<Room>();

  _HomeRouteState(List<Room> rooms){
    this.rooms = rooms;

    func();
  }

  Future func() async{
    await BluetoothFunctionality_SingleDevice.mapRoomsWithBluetoothDevices(rooms);

    await funcMic(0);
    await funcMic(1);
  }

  Future funcMic(int index) async{
    await BluetoothFunctionality_SingleDevice.connect(rooms.elementAt(index).bluetoothDevice);
    Uint8List msg;
    try {
      msg = BluetoothFunctionality_SingleDevice.readMessageFromBluetooth();
    }
    catch(e){
      print(e);
    }
    await BluetoothFunctionality_SingleDevice.sendMessageViaBluetooth(rooms.elementAt(index).roomName + "\n");

    int temp = rooms.elementAt(index).desiredTemperature;
    if(rooms.elementAt(index).remote){
      temp += 64;
    }
    BluetoothFunctionality_SingleDevice.sendMessageViaBluetooth(String.fromCharCode(temp));
  }

  /// build function
  Widget build(BuildContext context){
    _context = context;

    // reads message from bluetooth every second
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
        });
      }
      catch(Exception){

      }
    });

    // the  actual interface is built here
    return Scaffold(
      appBar: AppBar(
        title: Text("My Home"),
      ),
     body: Container(
       child: _roomListViewBuilder(rooms),
     ),
    );
  }

  Widget _roomListViewBuilder(List<Room> rooms){
    // add a clickable list element for every room available
    Widget retValue = ListView(
      children: <Widget>[
        _roomBuider(rooms.elementAt(0)),
        _roomBuider(rooms.elementAt(1)),
      ],
    );

    return retValue;
  }

  Widget _roomBuider(Room room){
    double fontSize = 15;

    return GestureDetector(
      // actual list element look and functionality
        child: Container(
          child: Row(
            children: <Widget>[
              Text(
                room.roomName,
                style: TextStyle(fontSize: fontSize),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
          ),
        ),
      onTap: () { pushSecondPage(room); },
    );
  }

  /// push secondPage
  /// which opens the individual room view
  void pushSecondPage(Room room) async{
    RoomRoute currentRoom = RoomRoute(room);
    await Navigator.push(
      _context,
      MaterialPageRoute(builder: (context) => currentRoom),
    );

    setState(() {});
  }
}