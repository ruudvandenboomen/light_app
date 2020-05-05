import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
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
  static Room currentRoom;
  double sliderValue =
      currentRoom != null ? currentRoom.getAverageBrightness() : 0.0;
  Temperature currentTemp;
  bool sliderChanged = false;

  @override
  void initState() {
    super.initState();
    currentRoom = widget._rooms[0];
    sliderValue = currentRoom.getAverageBrightness();
    setState(() {});
  }

  setBrightness(double brightness) {
    currentRoom.lights.forEach((lamp) => lamp.brightness = brightness);
  }

  void changeCurrentRoom(Room room) {
    currentRoom = room;
    setState(() {});
  }

  double getSliderValue() {
    return sliderChanged ? sliderValue : currentRoom.getAverageBrightness();
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
              Container(
                height: 200,
                child: Container(
                  color: Colors.amber[300],
                ),
              ),
              Flexible(
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
                        height: 80,
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
                                          ? Theme.of(context).accentColor
                                          : Colors.grey,
                                    )),
                              ],
                            ))),
                        Flexible(
                          flex: 1,
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 500),
                                  child: sliderValue.toStringAsFixed(2) !=
                                              currentRoom
                                                  .getAverageBrightness()
                                                  .toStringAsFixed(2) &&
                                          sliderChanged
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text("Currently ",
                                                style: TextStyle(fontSize: 14)),
                                            Text(
                                                (currentRoom.getAverageBrightness() *
                                                        100)
                                                    .toStringAsFixed(0),
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text("%",
                                                style: TextStyle(fontSize: 14))
                                          ],
                                        )
                                      : SizedBox.shrink(),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    FaIcon(FontAwesomeIcons.solidSun,
                                        color: Theme.of(context).accentColor),
                                    Container(
                                      width: 5,
                                    ),
                                    Text(
                                        (getSliderValue() * 100)
                                            .toStringAsFixed(0),
                                        style: TextStyle(
                                            fontSize: 50,
                                            fontWeight: FontWeight.bold)),
                                    Text("%", style: TextStyle(fontSize: 24))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
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
                            activeColor: Theme.of(context).accentColor,
                            min: 0.0,
                            max: 1.0,
                            onChangeEnd: (brightness) {
                              sliderValue = brightness;
                              sliderChanged = true;
                            },
                            value: getSliderValue(),
                            onChanged: (brightness) {
                              sliderValue = brightness;
                              sliderChanged = true;
                              setState(() {});
                            },
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: RaisedButton(
                                    color: Theme.of(context).accentColor,
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
                        CupertinoPageRoute(
                            builder: (context) => OverviewPage(
                                currentRoom, widget._mqttClientWrapper))),
                    child: Card(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          height: 58,
                          padding: EdgeInsets.only(left: 20),
                          child: Row(
                            children: <Widget>[
                              FaIcon(FontAwesomeIcons.slidersH,
                                  color: Theme.of(context).accentColor,
                                  size: 24),
                              Container(width: 15),
                              Text("Tune Lights",
                                  style: TextStyle(fontSize: 20))
                            ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(right: 14),
                            child: Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.black,
                              size: 24,
                            ))
                      ],
                    )),
                  ),
                ),
                Container(
                  height: 20,
                ),
                widget._currentTemp != null
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Card(
                          child: Theme(
                            data: ThemeData(
                                dividerColor: Colors.transparent,
                                accentColor: Colors.black,
                                unselectedWidgetColor: Colors.black),
                            child: ExpansionTile(
                                title: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.wb_sunny,
                                      color: Theme.of(context).accentColor,
                                      size: 32,
                                    ),
                                    Container(width: 15),
                                    Text(
                                        "${widget._currentTemp.temperature.toStringAsFixed(0)}°C ",
                                        style: TextStyle(fontSize: 32)),
                                    Spacer(),
                                    Text(DateFormat('kk:mm \ndd-MM')
                                        .format(widget._currentTemp.measured))
                                  ],
                                ),
                                children: <Widget>[
                                  ListTile(
                                      title: Text(
                                    "Humidity: ${widget._currentTemp.humidity.toStringAsFixed(0)}%",
                                    style: TextStyle(fontSize: 18),
                                  )),
                                  ListTile(
                                      title: Text(
                                          "Pressure: ${widget._currentTemp.pressure.toStringAsFixed(0)} hPa",
                                          style: TextStyle(fontSize: 18)))
                                ]),
                          ),
                        ),
                      )
                    : Container(),
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
