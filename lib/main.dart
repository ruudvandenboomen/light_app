import 'package:flutter/material.dart';
import 'package:light_app/objects/light.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/pages/main_control_page.dart';
import 'package:light_app/pages/overview_page.dart';
import 'package:light_app/ui/round_slider_track_shape.dart';
import 'package:light_app/util/secret_loader.dart';

import 'mqtt/mqtt_wrapper.dart';
import 'util/secret.dart';

List<Light> _lamps = [
  Light("Light 1"),
  Light("Light 2"),
  Light("Light 3"),
  Light("Light 4"),
  Light("Light 5"),
  Light("Light 6"),
  Light("Light 7"),
  Light("Light 8"),
];
List<Room> lights = [
  Room("Tuinhuis", _lamps),
  Room("Woonkamer", [Light("Light 1"), Light("Light 1")]),
  Room("Keuken", [Light("Light 1")]),
  Room("Slaapkamer", [Light("Light 1"), Light("Light 1"), Light("Light 1")])
];

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  MQTTClientWrapper mqttClientWrapper;

  @override
  void initState() {
    super.initState();
    setup();
  }

  void setup() async {
    Secret secret = await SecretLoader(secretPath: "secrets.json").load();
    mqttClientWrapper = MQTTClientWrapper(secret.mqttHost, 'phone_client', 1883,
        () => whatToDoAfterConnect(), (message) => gotMessage(message),
        username: secret.mqttUsername, password: secret.mqttPassword);
    mqttClientWrapper.prepareMqttClient();
  }

  gotMessage(String message) {
    print(message);
  }

  whatToDoAfterConnect() {}

  @override
  Widget build(BuildContext context) {
    MainControlPage mainControlPage =
        MainControlPage(lights, mqttClientWrapper);
    OverviewPage overviewPage = OverviewPage(lights, mqttClientWrapper);

    return MaterialApp(
      theme: ThemeData(
          sliderTheme: Theme.of(context).sliderTheme.copyWith(
                trackHeight: 22.0,
                trackShape: RoundSliderTrackShape(),
                activeTrackColor: Colors.green,
              ),
          iconTheme: IconThemeData(color: Colors.white, size: 28)),
      home: mainControlPage,
      routes: <String, WidgetBuilder>{
        '/main': (BuildContext context) => mainControlPage,
        '/lights': (BuildContext context) => overviewPage,
      },
    );
  }
}
