import 'dart:convert';

import 'HomeRoute.dart';
import 'RoomRoute.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'Room.dart';
import 'dart:typed_data';

class BluetoothFunctionality_SingleDevice{
  static List<BluetoothDevice> results = List<BluetoothDevice>();
  static Uint8List _readBytes;

  static Future mapRoomsWithBluetoothDevices(List<Room> rooms) async{
    await _startDiscovery();
    if(results.length == 0){
      return;
    }

    rooms.elementAt(0).bluetoothDevice = results.elementAt(0);
    rooms.elementAt(1).bluetoothDevice = results.elementAt(1);

    _printForVerification();
  }

  /*static void mapRoomsWithBluetoothDevices(List<Room> rooms) async{
    await _startDiscovery();
    if(results.length == 0){
      return;
    }

    _printForVerification();
    
    for(BluetoothDevice device in results){
      await FlutterBluetoothSerial.instance.isConnected.then((isConnected) {
        if(!isConnected){
          FlutterBluetoothSerial.instance.connect(device);
          print("Connected to " + device.name + " - " + device.address);
        }
      });

      print("reading");
      await FlutterBluetoothSerial.instance.isConnected.then((isConnected) {
        print("1");
        if(isConnected){
          print("2");
          FlutterBluetoothSerial.instance.onRead().listen((msg) {
            print("3");
            if(msg != null) {
              for (Room room in rooms) {
                if (msg[0] == room.id) {
                  room.bluetoothDevice = device;
                  sendMessageViaBluetooth(room.roomName);
                  print(
                      "Matched " + room.roomName + " with " + device.name + " - " +
                          device.address);
                }
              }
            }
          });
        }
      });

      await FlutterBluetoothSerial.instance.disconnect();
    }

    await FlutterBluetoothSerial.instance.isConnected.then((isConnected) {
      if(!isConnected){
        FlutterBluetoothSerial.instance.connect(results.elementAt(0));
      }
    });
  }*/

  static void _printForVerification() {
    print("Number of connected devices: " + results.length.toString());
    
    for(BluetoothDevice device in results){
      print("Device name: " + device.name + " - " + device.address);
    }
  }
/*
  static Future _connect() async{
    FlutterBluetoothSerial.instance.isConnected.then((isConnected) {
      print("Trying to connect to " + results.elementAt(0).name + " - " + results.elementAt(0).address);

      if(!isConnected){
        FlutterBluetoothSerial.instance.connect(results.elementAt(0));
        print("Connected");
      }else{
        FlutterBluetoothSerial.instance.disconnect();
        FlutterBluetoothSerial.instance.connect(results.elementAt(0));
        print("already connected connected");
      }
    });
  }*/

  static Future _startDiscovery() async {
    results.clear();

    await FlutterBluetoothSerial.instance.getBondedDevices()
    .then((List<BluetoothDevice> bondedDevices){
      print("Total devices recognized: " + bondedDevices.length.toString());

      for(BluetoothDevice device in bondedDevices){
        if(device.name == "HC-05"){
          results.add(device);
        }
      }
    });
  }

  static Uint8List readMessageFromBluetooth(){
    FlutterBluetoothSerial.instance.isConnected.then((isConnected){
      if(isConnected){
        try {
          FlutterBluetoothSerial.instance.onRead().listen((msg){
            _readBytes = msg;
          });
        }
        catch(e){
          print(e);
        }
      }
    });

    return _readBytes;
  }

/*  void _connectToAllRooms(){
    for(BluetoothDiscoveryResult bluetoothDiscoveryResult in results){
      _connect(bluetoothDiscoveryResult);

      if(bluetoothDiscoveryResult.device.isBonded){
        _mapDeviceToRoom(bluetoothDiscoveryResult);
      }
    }
  }

  void _mapDeviceToRoom(BluetoothDiscoveryResult bluetoothDiscoveryResult){
    BluetoothConnection.toAddress(bluetoothDiscoveryResult.device.address).then((_connection) {
      connection = _connection;

      connection.input.listen(_onDataReceived).onDone(() {
        print("Connection done");
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });

    // TODO
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    *//*int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
          0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }*//*

    _processDataString(dataString);

    homeRouteLink.state.setState(() { });
    if(roomRouteLink != null){
      roomRouteLink.state.setState(() { });
    }
  }

  void _processDataString(String dataString){
    // TODO
  }
  
  void _connect(BluetoothDiscoveryResult result) async{
    try {
      bool bonded = false;
      if (!result.device.isBonded) {
        print('Bonding with ${result.device.address}...');
        bonded = await FlutterBluetoothSerial.instance
            .bondDeviceAtAddress(result.device.address);
        print(
            'Bonding with ${result.device.address} has ${bonded ? 'succed' : 'failed'}.');
      }
      results[results.indexOf(result)] = BluetoothDiscoveryResult(
        device: BluetoothDevice(
          name: result.device.name ?? '',
          address: result.device.address,
          type: result.device.type,
          bondState: bonded
            ? BluetoothBondState.bonded
            : BluetoothBondState.none,
          ),
          rssi: result.rssi);
    } catch (ex) {
      *//*showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error occured while bonding'),
            content: Text("${ex.toString()}"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );*//*
    }
  }*/
/*
  static void connect(){
    // future_bluetooth_serial library predefined type of mapped List
    Future<List> _devices = _bluetooth.getBondedDevices();

    _devices.then((element){
      _device = element.first;
      print(_device.name + " is the name");
      _actualConnect();
      return;
    });
  }

*/
  // connects _bluetooth to the bluetooth _device
  static Future connect(BluetoothDevice device) async{
    BluetoothDevice _device;
    print("toggleConnect - results.length " + results.length.toString());

    for(BluetoothDevice d in results){
      print("trying to match with " + d.name + " - " + d.address);
      if(d == device){
        _device = d;
        print("matched with " + _device.name + " - " + _device.address);
      }
    }

    await FlutterBluetoothSerial.instance.getBondedDevices().then((devices) async{
      print("trying to connect");

      if(_device != null){
        print("_device.connect not null");

        await FlutterBluetoothSerial.instance.isConnected.then((isConnected) async{
          if(!isConnected){
            await FlutterBluetoothSerial.instance.connect(_device);
            print("connected to " + _device.name + " - " + _device.address);
          }else{
            await FlutterBluetoothSerial.instance.disconnect();
            await FlutterBluetoothSerial.instance.connect(_device);
            print("REconnected to " + _device.name + " - " + _device.address);
          }
        });
      }else{
        print("_device.connect null");
      }
    });
  }

  static Future disconnect() async{
    await FlutterBluetoothSerial.instance.isConnected.then((isConnected) async{
      if(isConnected){
        await FlutterBluetoothSerial.instance.disconnect();
      }
    });
  }


  static Future sendMessageViaBluetooth(String message) async{
    print("sending");
    FlutterBluetoothSerial.instance.isConnected.then((isConnected){
      print("trying to send");
      if(isConnected){
        FlutterBluetoothSerial.instance.write(message);
        print("sent " + message);
      }
    });
  }

/*
  // read message from _bluetooth
  static String readMessageFromBluetooth(){
    _bluetooth.isConnected.then((isConnected){
      if(isConnected){
        _bluetooth.onRead().listen((msg){
          //_sensorReadString = msg;
        });
      }
    });

    //print("aux = " +  _sensorReadString);
    return _sensorReadString;
  }


  // returns bluetooth device name or "none"
  // used to display the name in the interface
  String getBluetoothDeviceName(){
    if(_device == null){
      _deviceNameString = "none";
    }else{
      _bluetooth.isAvailable.then((isConnected) {
        if(isConnected){
          _deviceNameString = _device.name;
        }else{
          _deviceNameString =  "not connected";
        }

        return _deviceNameString;
      });
    }

    //print("s is " + s);
    return _deviceNameString;
  }
*/
}