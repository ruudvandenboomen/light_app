import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:light_app/mqtt/mqtt_wrapper.dart';
import 'package:light_app/objects/preset.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/pages/preset_page.dart';
import 'package:light_app/ui/custom_switch.dart';
import 'package:light_app/ui/main_information_widget.dart';
import 'package:light_app/ui/preset_list_item.dart';
import 'package:light_app/ui/round_slider_track_shape.dart';
import 'package:light_app/util/database_service.dart';
import 'package:provider/provider.dart';

import 'overview_page.dart';

class MainControlPage extends StatefulWidget {
  const MainControlPage();

  @override
  State<StatefulWidget> createState() => MainControlPageState();
}

class MainControlPageState extends State<MainControlPage>
    with WidgetsBindingObserver {
  MQTTClientWrapper mqttClientWrapper;
  static Room currentRoom;
  bool sliderChanged = false;
  PageController pageController = PageController(initialPage: 0);
  DatabaseService dbService = DatabaseService();
  Future<List<Preset>> presets;

  @override
  void initState() {
    super.initState();
    currentRoom = Provider.of<Room>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    presets = dbService.getPresets();
    mqttClientWrapper = MQTTClientWrapper.instance;
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
              MqttCurrentConnectionState.CONNECTED) {
        mqttClientWrapper.prepareMqttClient();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    presets = dbService.getPresets();
  }

  void setBrightness(double brightness) {
    for (var lamp in currentRoom.lights) {
      lamp.brightness = brightness;
    }
  }

  void changeCurrentRoom(Room room) {
    currentRoom = room;
    setState(() {});
  }

  void publishMessage(String message) {
    mqttClientWrapper.publishMessage(message);
  }

  void _awaitPresetPage(BuildContext context) async {
    // start the SecondScreen and wait for it to finish with a result
    var newPreset = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PresetPage(
              Preset('Preset ${currentRoom.presets.length + 1}', currentRoom)),
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
        child: SizedBox(
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
          onPageChanged: (page) {
            debugPrint('Page Changes to index $page');
          },
          children: [
            Consumer<Room>(
              builder: (context, room, child) {
                return SingleChildScrollView(
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
                                  'Tuinhuis',
                                  style: TextStyle(
                                      fontFamily: 'Ubuntu',
                                      fontSize: 45,
                                      color: Colors.white),
                                ),
                                CustomSwitch(
                                  value: currentRoom.lightOn(),
                                  onChanged: (bool value) {
                                    if (value == true) {
                                      var brightness = 0.5;
                                      currentRoom.setLightState(
                                          brightness, true);
                                    } else {
                                      var brightness = 0;
                                      currentRoom.setLightState(
                                          brightness.toDouble(), false);
                                    }
                                    publishMessage(
                                        jsonEncode(currentRoom.toJson()));
                                    setState(() {});
                                  },
                                )
                              ],
                            ),
                            MainInformationWidget(
                                currentRoom, currentRoom.temperature),
                            Container(height: 20),
                            Container(
                              child: Column(
                                children: <Widget>[
                                  SliderTheme(
                                    data: Theme.of(context)
                                        .sliderTheme
                                        .copyWith(
                                          trackHeight: 30.0,
                                          thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius: 15),
                                          trackShape: RoundSliderTrackShape(),
                                          activeTrackColor: Colors.green,
                                        ),
                                    child: Slider(
                                      divisions: 10,
                                      inactiveColor: Colors.grey[100],
                                      activeColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      min: 0.0,
                                      max: 1.0,
                                      onChangeEnd: (brightness) {
                                        currentRoom.setLightState(
                                            brightness, true);
                                        publishMessage(
                                            jsonEncode(currentRoom.toJson()));
                                        sliderChanged = true;
                                      },
                                      value: Provider.of<Room>(context,
                                              listen: false)
                                          .getAverageBrightness(),
                                      onChanged: (brightness) {
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
                              height: 10,
                            ),
                            Column(children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Presets',
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.green[300],
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.add, size: 28),
                                      color: Colors.green[300],
                                      onPressed: () =>
                                          _awaitPresetPage(context))
                                ],
                              ),
                              FutureBuilder(
                                builder: (context, presets) {
                                  if (presets.connectionState ==
                                          ConnectionState.done &&
                                      presets.hasData) {
                                    if (presets.data.length > 0) {
                                      currentRoom.presets = presets.data;
                                      currentRoom.checkIfPresetIsActive();
                                      return SizedBox(
                                        height: (presets.data.length * 70) +
                                            30.toDouble(),
                                        child: ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: presets.data.length,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 15),
                                            itemBuilder: (context, i) {
                                              return PresetListItem(
                                                  presets.data[i],
                                                  currentRoom,
                                                  update);
                                            }),
                                      );
                                    } else {
                                      return Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Text(
                                              'Je hebt nog geen presets ingesteld',
                                              style: TextStyle(fontSize: 16)));
                                    }
                                  }
                                  return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
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
                );
              },
            ),
            OverviewPage()
          ]),
    );
  }
}
