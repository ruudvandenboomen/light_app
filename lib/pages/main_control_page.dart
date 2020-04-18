import 'package:flutter/material.dart';
import 'package:light_app/mqtt/mqtt_wrapper.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/ui/custom_navigation.dart';
import 'package:light_app/ui/main_control.dart';
import 'package:light_app/ui/room_selector.dart';

class MainControlPage extends StatefulWidget {
  final List<Room> _rooms;
  final MQTTClientWrapper _mqttClientWrapper;

  MainControlPage(this._rooms, this._mqttClientWrapper);

  @override
  State<StatefulWidget> createState() => MainControlPageState();
}

class MainControlPageState extends State<MainControlPage> {
  Room currentRoom;
  double sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    currentRoom = widget._rooms[0];
  }

  setBrightness(double brightness) {
    currentRoom.getLights().forEach((lamp) => lamp.setBrightness(brightness));
  }

  void changeCurrentRoom(Room room) {
    this.currentRoom = room;
    setState(() {});
  }

  void changeSliderValue(double value) {
    this.sliderValue = value;
    setState(() {});
  }

//  widget._mqttClientWrapper .publishMessage(jsonEncode(currentRoom.toJson()))

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(20, 40, 20, 10),
              child: Text(
                "Main Control",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              )),
          Container(
              height: 60,
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: ScrollConfiguration(
                  behavior: ScrollBehavior(),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget._rooms.length,
                      itemBuilder: (BuildContext context, int index) {
                        Room room = widget._rooms[index];
                        return RoomSelectorWidget(
                            room, currentRoom, changeCurrentRoom);
                      }))),
          Expanded(child: MainControlWidget(sliderValue, changeSliderValue))
        ],
      ),
      bottomNavigationBar: CustomNavigation(1),
    );
  }
}
