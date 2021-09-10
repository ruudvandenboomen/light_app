import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:light_app/mqtt/mqtt_wrapper.dart';
import 'package:light_app/objects/light.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/pages/main_control_page.dart';
import 'package:light_app/ui/round_slider_track_shape.dart';
import 'package:light_app/util/database_service.dart';
import 'package:provider/provider.dart';

List<Light> _lamps = [
  Light('Lamp 1'),
  Light('Lamp 2'),
  Light('Lamp 3'),
  Light('Lamp 4'),
  Light('Lamp 5'),
  Light('Lamp 6'),
  Light('Lamp 7'),
  Light('Lamp 8'),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseService();
  runApp(ChangeNotifierProvider(
    create: (context) => Room('Tuinhuis', _lamps),
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  State createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initMqttClient();
  }

  void initMqttClient() async {
    const mqttHost = String.fromEnvironment('MQTT_HOST');
    const mqttUsername = String.fromEnvironment('MQTT_USERNAME');
    const mqttPassword = String.fromEnvironment('MQTT_PASSWORD');

    var client = await _getClientName();
    MQTTClientWrapper(mqttHost, client, 1883, () => {}, context,
        username: mqttUsername, password: mqttPassword);
  }

  Future<String> _getClientName() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    String identifier;
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        //UUID for Android
        identifier = build.androidId;
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        //UUID for iOS
        identifier = data.identifierForVendor;
      }
    } on PlatformException {
      debugPrint('Failed to get platform version');
    }
    return 'phone_client_$identifier';
  }

  @override
  Widget build(BuildContext context) {
    var mainControlPage = MainControlPage();
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.green[300],
          sliderTheme: Theme.of(context).sliderTheme.copyWith(
                trackHeight: 22.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 11),
                trackShape: RoundSliderTrackShape(),
                tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 0),
                activeTrackColor: Colors.green,
              ),
          textTheme: TextTheme(
            headline1: TextStyle(fontFamily: 'Ubuntu'),
            headline2: TextStyle(fontFamily: 'Ubuntu'),
            button: TextStyle(fontFamily: 'Ubuntu'),
            bodyText1: TextStyle(fontFamily: 'PTSans'),
            bodyText2: TextStyle(fontFamily: 'PTSans'),
          ),
          iconTheme: IconThemeData(color: Colors.white, size: 28), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.green[200])),
      debugShowCheckedModeBanner: false,
      home: mainControlPage,
      routes: <String, WidgetBuilder>{
        '/main': (BuildContext context) => mainControlPage,
      },
    );
  }
}
