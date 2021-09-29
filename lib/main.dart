import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:light_app/mqtt/mqtt_wrapper.dart';
import 'package:light_app/objects/light.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/pages/onboarding/login_page.dart';
import 'package:light_app/pages/main_control_page.dart';
import 'package:light_app/ui/round_slider_track_shape.dart';
import 'package:light_app/util/database_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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
  var sharedPreferences = await SharedPreferences.getInstance();
  String token = sharedPreferences.get('token');
  var isLoggedIn = token != null;
  runApp(ChangeNotifierProvider(
    create: (context) => Room('Tuinhuis', _lamps),
    child: MyApp(isLoggedIn),
  ));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  MyApp(this.isLoggedIn);

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

    var client = _getClientName();
    MQTTClientWrapper(mqttHost, client, 1883, () => {}, context,
        username: mqttUsername, password: mqttPassword);
  }

  String _getClientName() {
    var uuid = Uuid();
    return 'client_$uuid';
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
            headline1: TextStyle(
                fontFamily: 'Ubuntu', color: Colors.white, fontSize: 32),
            headline2: TextStyle(fontFamily: 'Ubuntu'),
            button: TextStyle(fontFamily: 'Ubuntu'),
            bodyText1: TextStyle(fontFamily: 'PTSans'),
            bodyText2: TextStyle(fontFamily: 'PTSans'),
          ),
          iconTheme: IconThemeData(color: Colors.white, size: 28),
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.green[200])),
      debugShowCheckedModeBanner: false,
      home: widget.isLoggedIn ? MainControlPage() : LoginPage(),
      routes: <String, WidgetBuilder>{
        '/main': (BuildContext context) => mainControlPage,
      },
    );
  }
}
