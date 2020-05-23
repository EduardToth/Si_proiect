import 'package:flutter/material.dart';
import 'HomeRoute.dart';
import 'Room.dart';

const Color MainThemeColor = Colors.blue;

const Color ColorIsOnAuto = Colors.white;
const Color ColorNotIsOnAuto = Colors.orange;

void main() {
  List<Room> rooms = new List<Room>();
  rooms.add(new Room(0, "Living Room", 10000, false));
  rooms.add(new Room(1, "Bed Room", 28, true));

  runApp(MyApp(rooms));
}

class MyApp extends StatelessWidget {
  List<Room> rooms;

  MyApp(List<Room> rooms){
    this.rooms = rooms;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print("started app");

    return MaterialApp(
      title: 'My Home',
      theme: ThemeData(
        primarySwatch: MainThemeColor,
      ),
      home: HomeRoute(rooms),
    );
  }
}