import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:light_app/mqtt/mqtt_wrapper.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/objects/temperature.dart';
import 'package:light_app/ui/room_selector.dart';
import 'package:light_app/ui/round_slider_track_shape.dart';

import 'overview_page.dart';

class MainControlPage extends StatefulWidget {
  final List<Room> _rooms;
  final MQTTClientWrapper _mqttClientWrapper;
  final Temperature _currentTemp;

  MainControlPage(this._rooms, this._mqttClientWrapper, this._currentTemp);

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
    currentRoom.lights.forEach((lamp) => lamp.brightness = brightness);
  }

  void changeCurrentRoom(Room room) {
    this.currentRoom = room;
    setState(() {});
  }

  void changeSliderValue(double value) {
    this.sliderValue = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Light App",
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.amber[300],
      ),
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Container(
                  color: Colors.amber[300],
                ),
              ),
              Flexible(
                flex: 3,
                child: Container(
                  color: Colors.grey[100],
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          currentRoom.name.toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 52,
                              fontWeight: FontWeight.bold),
                        )),
                    Container(
                      height: 50,
                      child: ScrollConfiguration(
                        behavior: ScrollBehavior(),
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: widget._rooms.length,
                            itemBuilder: (BuildContext context, int index) {
                              Room room = widget._rooms[index];
                              var roomSelector = Center(
                                  child: RoomSelectorWidget(
                                      room, currentRoom, changeCurrentRoom));
                              if (index == widget._rooms.length - 1) {
                                return Row(
                                  children: <Widget>[
                                    roomSelector,
                                    Container(
                                        width: 50,
                                        child: Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        40.0)),
                                            child: IconButton(
                                              icon: Icon(Icons.add),
                                              color: Colors.grey,
                                              onPressed: () {},
                                            ))),
                                  ],
                                );
                              }
                              return roomSelector;
                            }),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    height: 100,
                    child: Row(
                      children: <Widget>[
                        Flexible(
                            flex: 1,
                            child: Card(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text("STATE",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16)),
                                Text(currentRoom.lightOn() ? "ON" : "OFF",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 50,
                                      fontWeight: FontWeight.w900,
                                      color: currentRoom.lightOn()
                                          ? Colors.amber[200]
                                          : Colors.grey,
                                    )),
                              ],
                            ))),
                        Flexible(
                            flex: 1,
                            child: Card(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                FaIcon(FontAwesomeIcons.solidSun,
                                    color: Colors.amber[200]),
                                Container(
                                  width: 5,
                                ),
                                Text((sliderValue * 100).toStringAsFixed(0),
                                    style: TextStyle(
                                        fontSize: 50,
                                        fontWeight: FontWeight.bold)),
                                Text("%", style: TextStyle(fontSize: 24))
                              ],
                            )))
                      ],
                    ),
                  ),
                ),
                Container(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        SliderTheme(
                          data: Theme.of(context).sliderTheme.copyWith(
                                trackHeight: 30.0,
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 15),
                                trackShape: RoundSliderTrackShape(),
                                activeTrackColor: Colors.green,
                              ),
                          child: Slider(
                            divisions: 10,
                            inactiveColor: Colors.grey[100],
                            activeColor: Colors.amber[100],
                            min: 0.0,
                            max: 1.0,
                            onChangeEnd: (brightness) =>
                                sliderValue = brightness,
                            value: sliderValue,
                            onChanged: (brightness) {
                              sliderValue = brightness;
                              setState(() {});
                            },
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: RaisedButton(
                                    color: Colors.amber[200],
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Text("TURN ON"),
                                    onPressed: () {
                                      currentRoom.setLightState(
                                          sliderValue, true);
                                      widget._mqttClientWrapper.publishMessage(
                                          jsonEncode(currentRoom.toJson()));
                                      setState(() {});
                                    })),
                            Expanded(
                                child: RaisedButton(
                                    color: Colors.grey[200],
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Text("TURN OFF"),
                                    onPressed: () {
                                      currentRoom.setLightState(0.0, false);
                                      sliderValue = 0;
                                      widget._mqttClientWrapper.publishMessage(
                                          jsonEncode(currentRoom.toJson()));
                                      setState(() {});
                                    }))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OverviewPage(
                                currentRoom, widget._mqttClientWrapper))),
                    child: Card(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Row(
                            children: <Widget>[
                              FaIcon(FontAwesomeIcons.slidersH,
                                  color: Colors.amber[200], size: 20),
                              Container(width: 5),
                              Text("Tune Lights",
                                  style: TextStyle(fontSize: 20))
                            ],
                          ),
                        ),
                        IconButton(
                          color: Colors.grey,
                          icon: Icon(Icons.navigate_next),
                          onPressed: () {},
                        )
                      ],
                    )),
                  ),
                ),
                Container(
                  height: 20,
                ),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Card(
                        child: ExpansionTile(
                            title: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.wb_sunny,
                                  color: Colors.amber[200],
                                ),
                                Text(
                                    widget._currentTemp != null
                                        ? "Temperature: ${widget._currentTemp.temperature.toStringAsFixed(0)}°C"
                                        : "Temperature",
                                    style: TextStyle(fontSize: 20))
                              ],
                            ),
                            children: <Widget>[
                          ListTile(
                              title: Text(
                                  widget._currentTemp != null
                                      ? "Humidity: ${widget._currentTemp.humidity.toStringAsFixed(0)}°C"
                                      : "Humidity",
                                  style: TextStyle(fontSize: 18)))
                        ]))),
                Container(
                  height: 20,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//onPressed: () {
//Navigator.pushNamed(context, "/lights");
