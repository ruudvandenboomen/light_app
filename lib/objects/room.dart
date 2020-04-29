import 'light.dart';

class Room {
  String name;
  List<Light> lights;

  Room(this.name, this.lights);

  bool lightOn() {
    bool lightOn = false;
    for (Light light in this.lights) {
      if (light.brightness > 0) {
        lightOn = true;
        break;
      }
    }
    return lightOn;
  }

  setLightState(double brightness, bool turnedOn) {
    for (Light light in this.lights) {
      light.turnedOn = turnedOn;
      light.brightness = brightness;
    }
  }

  double getAverageBrightness() {
    return this.lights.map((e) => e.brightness).reduce((a, b) => a + b) /
        this.lights.length;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    List<double> brightnesses = List();
    for (var i = 0; i < lights.length; i++) {
      Light light = lights[i];
      //TODO: change that 1 is of and 0 is on when lights won't work reversed anymore
      if (light.turnedOn)
        brightnesses
            .add(double.parse((1.0 - lights[i].brightness).toStringAsFixed(2)));
      else
        brightnesses.add(1.0);
    }
    map.putIfAbsent(this.name, () => brightnesses);
    return map;
  }

  fromJson(Map<String, dynamic> json) {
    List<dynamic> brightnesses = json[name];
    for (var i = 0; i < lights.length; i++) {
      double brightness = brightnesses[i].toDouble();
      //TODO: change 1 to 0 when lights won't work reversed anymore
      lights[i].brightness = 1.0 - brightness;
      lights[i].turnedOn = brightness < 1;
    }
  }
}
