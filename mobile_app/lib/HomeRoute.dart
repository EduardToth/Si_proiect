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

  /// push secondPage
  static void pushSecondPage(){
    //_HomeRouteState.pushSecondPage();
  }


  // get bluetooth device name
  static String getBluetoothDeviceName(){
    //return _HomeRouteState.getBluetoothDeviceName();
  }

  static bool getAutomatic(){
    //return _HomeRouteState.automatic;
  }

  static void automaticPress(){
    //_HomeRouteState._automaticPress();
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

    print("starting sending");

    Uint8List msg;
    try {
      msg = BluetoothFunctionality_SingleDevice.readMessageFromBluetooth();
    }
    catch(e){
      print(e);
    }
    print("read now " + msg.toString());

    print("matched; sending room name");
    await BluetoothFunctionality_SingleDevice.sendMessageViaBluetooth(rooms.elementAt(index).roomName + "\n");

    int temp = rooms.elementAt(index).desiredTemperature;
    if(rooms.elementAt(index).remote){
      temp += 64;
    }
    BluetoothFunctionality_SingleDevice.sendMessageViaBluetooth(String.fromCharCode(temp));

    await BluetoothFunctionality_SingleDevice.disconnect();
    print("got disconnected");
  }

  /// build function
  Widget build(BuildContext context){
    _context = context;

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
            //print("Main Page is reading: " + msg.toString());
          }
          else{
            //print("Not reading anything");
          }
        });
      }
      catch(Exception){
        print("exited main");
      }
    });

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

/*
  /// send message
  static void _sendMessage(){
    var aux;

    // automatic
    if(automatic){
      aux = _messageToSend.automatic;
    }

    else{

      // up
      if(_up){
        if(_left){
          aux = _messageToSend.up_left;
        }else if(_right){
          aux = _messageToSend.up_right;
        }else{
          aux = _messageToSend.up;
        }
      }

      // down
      else if(_down){
        if(_left){
          aux = _messageToSend.down_left;
        }else if(_right){
          aux = _messageToSend.down_right;
        }else{
          aux = _messageToSend.down;
        }
      }

      // just left or right
      else if(_left){
        aux = _messageToSend.left;
      }else if(_right){
        aux = _messageToSend.right;
      }

      // stop
      else{
        aux = _messageToSend.stop;
      }

    }

    _bluetoothDevice.sendMessageViaBluetooth(aux.index.toString());
    print("printed: " + aux.toString() + " - " + aux.index.toString());
  }

*/
  /// push secondPage
  void pushSecondPage(Room room) async{
    RoomRoute currentRoom = RoomRoute(room);
    //_bluetooth.roomRouteLink = currentRoom;

    await Navigator.push(
      _context,
      MaterialPageRoute(builder: (context) => currentRoom),
    );

    //_bluetooth.roomRouteLink = null;
    setState(() {});

    /*Navigator.push(context, new MaterialPageRoute<String>(
        builder: (BuildContext context) {
          return new Center(
            child: new GestureDetector(
                child: new Text('OK'),
                onTap: () { Navigator.pop(context, "Audio1"); }
            ),
          );
        },
    )
    );*/

    /*Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(room.desiredTemperature.toString()),
      )
    );*/
  }

/*
  // get bluetooth device name
  static String getBluetoothDeviceName(){
    return _bluetoothDevice.getBluetoothDeviceName();
  }
*/
}