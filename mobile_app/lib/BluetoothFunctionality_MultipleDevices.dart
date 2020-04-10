import 'HomeRoute.dart';
import 'RoomRoute.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'Room.dart';
import 'dart:typed_data';

class BluetoothFunctionality_MultipleDevices{
  List<BluetoothDiscoveryResult> results = List<BluetoothDiscoveryResult>();
  bool isDiscovering = true;
  BluetoothConnection connection;

  HomeRoute homeRouteLink;
  RoomRoute roomRouteLink;
  List<Room> rooms = new List<Room>();

  // the actual device
  // if this is null, then there is no device
  static BluetoothDevice _device;

  String _deviceNameString = "aaa";
  static String _sensorReadString = "bbb";

  // constructor
  BluetoothFunctionality_MultipleDevices(List<Room> rooms){
    //FlutterBluetoothSerial.instance.requestEnable();
    this.rooms = rooms;

    _startDiscovery();
    _connectToAllRooms();
  }

  void _startDiscovery() async {
    results.clear();
    FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      results.add(r);
    }).onDone(() {
      isDiscovering = false;
    });

    /*List<BluetoothDevice> res = new List<BluetoothDevice>();

    await FlutterBluetoothSerial.instance.getBondedDevices()
    .then((List<BluetoothDevice> bondedDevices){
      print("Total devices recognized: " + bondedDevices.length.toString());

      for(BluetoothDevice device in bondedDevices){
        if(device.name == "HC-05"){
          res.add(device);
        }
      }
    });
    print("Number of connected devices: " + res.length.toString());

    for(BluetoothDevice device in res){
      print("Device name: " + device.name + " - " + device.address);
    }*/

    /*FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
        Iterator i = devices.iterator;
        while (i.moveNext()) {
          var _device = i.current;
          if (_device.device == r.device) {
            _device.availability = _DeviceAvailability.yes;
            _device.rssi = r.rssi;
          }
        }
    });*/
  }

  void _connectToAllRooms(){
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
    /*int index = buffer.indexOf(13);
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
    }*/

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
      /*showDialog(
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
      );*/
    }
  }
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


  // connects _bluetooth to the bluetooth _device
  static void _actualConnect(){
    print("trying to connect");

    if(_device != null){
      print("_device.connect not null");

      _bluetooth.isConnected.then((isConnected) {
        if(!isConnected){
          _bluetooth.connect(_device);
          print("connected");
        }else{
          _bluetooth.disconnect();
          _bluetooth.connect(_device);
          print("already connected connected");
        }
      });
    }else{
      print("_device.connect null");
    }
  }


  // send messages via _bluetooth
  void sendMessageViaBluetooth(String message){
    _bluetooth.isConnected.then((isConnected){
      if(isConnected){
        _bluetooth.write(message[0]);
        print("sent " + message);
      }
    });
  }


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