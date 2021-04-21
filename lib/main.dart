import 'package:flutter/material.dart';
import 'package:light_app/objects/light.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/pages/main_control_page.dart';
import 'package:light_app/ui/round_slider_track_shape.dart';
import 'package:light_app/util/database_service.dart';
import 'package:light_app/util/secret.dart';
import 'package:light_app/util/secret_loader.dart';

import 'objects/preset.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseService();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  static List<Light> _lamps = [
    Light("Lamp 1"),
    Light("Lamp 2"),
    Light("Lamp 3"),
    Light("Lamp 4"),
    Light("Lamp 5"),
    Light("Lamp 6"),
    Light("Lamp 7"),
    Light("Lamp 8"),
  ];
  List<Room> rooms = [
    Room("Tuinhuis", _lamps),
  ];
  Secret secret;

  @override
  void initState() {
    super.initState();
    setup();
  }

  void setup() async {
    if (secret == null) {
      secret = await SecretLoader(secretPath: "secrets.json").load();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    MainControlPage mainControlPage = MainControlPage(rooms, secret);

    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.green[300],
          accentColor: Colors.green[200],
          sliderTheme: Theme.of(context).sliderTheme.copyWith(
                trackHeight: 22.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 11),
                trackShape: RoundSliderTrackShape(),
                activeTrackColor: Colors.green,
              ),
          textTheme: TextTheme(
            headline1: TextStyle(fontFamily: "Ubuntu"),
            headline2: TextStyle(fontFamily: "Ubuntu"),
            button: TextStyle(fontFamily: "Ubuntu"),
            bodyText1: TextStyle(fontFamily: "PTSans"),
            bodyText2: TextStyle(fontFamily: "PTSans"),
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
