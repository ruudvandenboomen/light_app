import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:light_app/mqtt/mqtt_wrapper.dart';
import 'package:light_app/objects/preset.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/objects/temperature.dart';
import 'package:light_app/pages/preset_page.dart';
import 'package:light_app/ui/custom_switch.dart';
import 'package:light_app/ui/main_information_widget.dart';
import 'package:light_app/ui/preset_list_item.dart';
import 'package:light_app/ui/round_slider_track_shape.dart';
import 'package:light_app/util/database_service.dart';
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
  DatabaseService dbService = DatabaseService();
  Future<List<Preset>> presets;

  @override
  void initState() {
    super.initState();
    currentRoom = widget._rooms[0];
    sliderValue = currentRoom.getAverageBrightness();
    setupMqttClientWrapper();
    WidgetsBinding.instance.addObserver(this);
    presets = dbService.getPresets();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    presets = dbService.getPresets();
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

  void _awaitPresetPage(BuildContext context) async {
    // start the SecondScreen and wait for it to finish with a result
    Preset newPreset = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PresetPage(
              Preset("Preset ${currentRoom.presets.length + 1}", currentRoom)),
        ));

    if (newPreset != null) {
      await dbService.insertPreset(newPreset);
      presets = dbService.getPresets();
      currentRoom.presets.add(newPreset);
    }
    setState(() {});
  }

  void update() {
    setState(() {});
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
            SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.green[300],
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        Container(
                          height: 65,
                        ),
                        Row(
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
                                publishMessage(
                                    jsonEncode(currentRoom.toJson()));
                                this.setState(() {});
                              },
                            )
                          ],
                        ),
                        MainInformationWidget(currentRoom, currentTemp),
                        Container(height: 20),
                        Container(
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
                                    currentRoom.setLightState(brightness, true);
                                    publishMessage(
                                        jsonEncode(currentRoom.toJson()));
                                    sliderChanged = true;
                                  },
                                  value: getSliderValue(),
                                  onChanged: (brightness) {
                                    sliderValue = brightness;
                                    currentRoom.setLightState(brightness, true);
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
                          height: 10,
                        ),
                        Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Presets",
                                style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.green[300],
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                  icon: Icon(Icons.add, size: 28),
                                  color: Colors.green[300],
                                  onPressed: () => _awaitPresetPage(context))
                            ],
                          ),
                          FutureBuilder(
                            builder: (context, presets) {
                              if (presets.connectionState ==
                                      ConnectionState.done &&
                                  presets.hasData) {
                                if (presets.data.length > 0) {
                                  currentRoom.presets = presets.data;
                                  return Container(
                                    height: (presets.data.length * 70) +
                                        30.toDouble(),
                                    child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: presets.data.length,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 15),
                                        itemBuilder: (context, i) {
                                          return PresetListItem(presets.data[i],
                                              currentRoom, update);
                                        }),
                                  );
                                } else {
                                  return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Text(
                                          "Je hebt nog geen presets ingesteld",
                                          style: TextStyle(fontSize: 16)));
                                }
                              }
                              return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: CircularProgressIndicator());
                            },
                            future: presets,
                          )
                        ])
                      ],
                    ),
                  ),
                ],
              ),
            ),
            OverviewPage(currentRoom, mqttClientWrapper)
          ]),
    );
  }
}
