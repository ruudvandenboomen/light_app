import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:light_app/mqtt/mqtt_wrapper.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/objects/temperature.dart';
import 'package:light_app/ui/animated_count.dart';
import 'package:light_app/ui/custom_switch.dart';
import 'package:light_app/ui/round_slider_track_shape.dart';
import 'package:light_app/util/secret.dart';
import 'package:light_app/util/secret_loader.dart';

import 'overview_page.dart';

class MainControlPage extends StatefulWidget {
  final List<Room> _rooms;
  final Secret _secret;

  MainControlPage(this._rooms, this._secret);

  @override
  State<StatefulWidget> createState() => MainControlPageState();
}

class MainControlPageState extends State<MainControlPage>
    with WidgetsBindingObserver {
  MQTTClientWrapper mqttClientWrapper;
  static Room currentRoom;
  Temperature currentTemp;
  double sliderValue =
      currentRoom != null ? currentRoom.getAverageBrightness() : 0.0;
  bool sliderChanged = false;
  PageController pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    currentRoom = widget._rooms[0];
    sliderValue = currentRoom.getAverageBrightness();
    setupMqttClientWrapper();
    WidgetsBinding.instance.addObserver(this);
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      if (state == AppLifecycleState.resumed &&
          mqttClientWrapper.connectionState !=
              MqttCurrentConnectionState.CONNECTED)
        mqttClientWrapper.prepareMqttClient();
    });
  }

  setupMqttClientWrapper() async {
    Secret secret = await SecretLoader(secretPath: "secrets.json").load();
    mqttClientWrapper = MQTTClientWrapper(secret.mqttHost, 'phone_client', 1883,
        () => {}, (message, topic) => gotMessage(message, topic),
        username: secret.mqttUsername, password: secret.mqttPassword);
    mqttClientWrapper.prepareMqttClient();
  }

  gotMessage(String message, String topic) {
    if (topic == MQTTClientWrapper.temperatureTopic) {
      this.currentTemp = Temperature.fromJson(jsonDecode(message));
      setState(() {});
    } else if (topic == MQTTClientWrapper.lightTopic) {
      widget._rooms[0].fromJson(jsonDecode(message));
      setState(() {});
    }
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

  publishMessage(String message) {
    mqttClientWrapper.publishMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  icon: Icon(Icons.home, size: 30),
                  color: Colors.green[300],
                  onPressed: () {
                    setState(() {
                      pageController.animateToPage(0,
                          duration: Duration(milliseconds: 250),
                          curve: Curves.linear);
                    });
                  }),
              IconButton(
                  icon: Icon(Icons.drag_indicator, size: 30),
                  color: Colors.green[300],
                  onPressed: () {
                    setState(() {
                      pageController.animateToPage(1,
                          duration: Duration(milliseconds: 250),
                          curve: Curves.linear);
                    });
                  })
            ],
          ),
        ),
      ),
      body: PageView(
          controller: pageController,
          onPageChanged: (int) {
            print('Page Changes to index $int');
          },
          children: [
            Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.green[300],
                  ),
                ),
                Positioned(
                    top: 200,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: mqttClientWrapper != null
                            ? Container(
                                padding: EdgeInsets.symmetric(horizontal: 25),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Container(
                                      height: 80,
                                    ),
                                    Container(height: 20),
                                    Container(
                                      child: Column(
                                        children: <Widget>[
                                          SliderTheme(
                                            data: Theme.of(context)
                                                .sliderTheme
                                                .copyWith(
                                                  trackHeight: 30.0,
                                                  thumbShape:
                                                      RoundSliderThumbShape(
                                                          enabledThumbRadius:
                                                              15),
                                                  trackShape:
                                                      RoundSliderTrackShape(),
                                                  activeTrackColor:
                                                      Colors.green,
                                                ),
                                            child: Slider(
                                              divisions: 10,
                                              inactiveColor: Colors.grey[100],
                                              activeColor:
                                                  Theme.of(context).accentColor,
                                              min: 0.0,
                                              max: 1.0,
                                              onChangeEnd: (brightness) {
                                                sliderValue = brightness;
                                                currentRoom.setLightState(
                                                    brightness, true);
                                                publishMessage(jsonEncode(
                                                    currentRoom.toJson()));
                                                sliderChanged = true;
                                              },
                                              value: getSliderValue(),
                                              onChanged: (brightness) {
                                                sliderValue = brightness;
                                                currentRoom.setLightState(
                                                    brightness, true);
                                                sliderChanged = true;
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 15,
                                    ),
                                    Divider(
                                      thickness: 1,
                                    ),
                                    Container(
                                      height: 15,
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Presets instellen",
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  color: Colors.green[300],
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add),
                                              color: Colors.green[300],
                                              onPressed: () {},
                                            )
                                          ],
                                        ),
                                        Text(
                                            "Je hebt nog geen presets ingesteld")
                                      ],
                                    )
                                  ],
                                ))
                            : CircularProgressIndicator())),
                Positioned(
                  top: 60,
                  left: 25,
                  right: 25,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tuinhuis",
                        style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontSize: 45,
                            color: Colors.white),
                      ),
                      CustomSwitch(
                        value: currentRoom.lightOn(),
                        onChanged: (bool value) {
                          if (value == true) {
                            double brightness = 0.5;
                            sliderValue = brightness;
                            currentRoom.setLightState(brightness, true);
                          } else {
                            double brightness = 0;
                            sliderValue = brightness;
                            currentRoom.setLightState(brightness, false);
                          }
                          publishMessage(jsonEncode(currentRoom.toJson()));
                          this.setState(() {});
                        },
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 25),
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                    flex: 1,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FaIcon(FontAwesomeIcons.lightbulb,
                                                color: Theme.of(context)
                                                    .accentColor),
                                            Container(
                                              width: 5,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                AnimatedCount(
                                                    duration:
                                                        Duration(seconds: 1),
                                                    count: (currentRoom
                                                                .getAverageBrightness() *
                                                            100)
                                                        .toInt(),
                                                    textStyle: TextStyle(
                                                        fontSize: 40)),
                                                Text("%",
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    )),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  child: VerticalDivider(
                                    thickness: 1,
                                  ),
                                ),
                                Flexible(
                                    flex: 1,
                                    child: currentTemp != null
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  FaIcon(
                                                      FontAwesomeIcons
                                                          .temperatureLow,
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                  Container(
                                                    width: 5,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "${currentTemp.temperature.toStringAsFixed(0)}",
                                                        style: TextStyle(
                                                            fontSize: 40),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      Text("°C",
                                                          style: TextStyle(
                                                              fontSize: 18)),
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          )
                                        : Container()),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            OverviewPage(currentRoom, mqttClientWrapper)
          ]),
    );
  }
}
