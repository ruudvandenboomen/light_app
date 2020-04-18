import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:light_app/mqtt/mqtt_wrapper.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/ui/custom_navigation.dart';
import 'package:light_app/ui/lamp_widget.dart';
import 'package:light_app/ui/room_selector.dart';

class OverviewPage extends StatefulWidget {
  final List<Room> _rooms;
  final MQTTClientWrapper _mqttClientWrapper;

  OverviewPage(this._rooms, this._mqttClientWrapper);

  @override
  State<StatefulWidget> createState() => OverviewPageState();
}

class OverviewPageState extends State<OverviewPage> {
  Room currentRoom;

  @override
  void initState() {
    super.initState();
    currentRoom = widget._rooms[0];
  }

  void update() {
    widget._mqttClientWrapper.publishMessage(jsonEncode(currentRoom.toJson()));
    setState(() {});
  }

  void changeCurrentRoom(Room room) {
    this.currentRoom = room;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavigation(0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(20, 40, 20, 10),
              child: Text(
                "Lights",
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
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: GridView.builder(
                itemCount: currentRoom.getLights().length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (MediaQuery.of(context).orientation ==
                            Orientation.portrait)
                        ? 2
                        : 3),
                itemBuilder: (BuildContext context, int index) {
                  return LampWidget(
                      currentRoom.getLights()[index], () => update());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
