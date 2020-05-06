import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:light_app/objects/light.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/pages/main_control_page.dart';
import 'package:light_app/ui/round_slider_track_shape.dart';
import 'package:light_app/util/secret_loader.dart';

import 'mqtt/mqtt_wrapper.dart';
import 'objects/temperature.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static List<Light> _lamps = [
    Light("Light 1"),
    Light("Light 2"),
    Light("Light 3"),
    Light("Light 4"),
    Light("Light 5"),
    Light("Light 6"),
    Light("Light 7"),
    Light("Light 8"),
  ];
  List<Room> rooms = [
    Room("Tuinhuis", _lamps),
  ];

  MQTTClientWrapper mqttClientWrapper;
  Temperature currentTemp;

  @override
  void initState() {
    super.initState();
    setup();
    WidgetsBinding.instance.addObserver(this);
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
              MqttCurrentConnectionState.CONNECTED) setup();
    });
  }

  void setup() {
    SecretLoader(secretPath: "secrets.json").load().then((secret) {
      mqttClientWrapper = MQTTClientWrapper(
          secret.mqttHost,
          'phone_client',
          1883,
          () => whatToDoAfterConnect(),
          (message, topic) => gotMessage(message, topic),
          username: secret.mqttUsername,
          password: secret.mqttPassword);
      mqttClientWrapper.prepareMqttClient();
      setState(() {});
    });
  }

  gotMessage(String message, String topic) {
    if (topic == MQTTClientWrapper.temperatureTopic) {
      this.currentTemp = Temperature.fromJson(jsonDecode(message));
      setState(() {});
    } else if (topic == MQTTClientWrapper.lightTopic) {
      rooms[0].fromJson(jsonDecode(message));
      setState(() {});
    }
  }

  whatToDoAfterConnect() {}

  @override
  Widget build(BuildContext context) {
    MainControlPage mainControlPage =
        MainControlPage(rooms, mqttClientWrapper, currentTemp);

    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.amber[300],
          accentColor: Colors.amber[200],
          sliderTheme: Theme.of(context).sliderTheme.copyWith(
                trackHeight: 22.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 11),
                trackShape: RoundSliderTrackShape(),
                activeTrackColor: Colors.green,
              ),
          iconTheme: IconThemeData(color: Colors.white, size: 28)),
      debugShowCheckedModeBanner: false,
      home: mainControlPage,
      routes: <String, WidgetBuilder>{
        '/main': (BuildContext context) => mainControlPage,
      },
    );
  }
}
