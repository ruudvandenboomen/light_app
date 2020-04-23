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
      if (light.turnedOn)
        brightnesses.add(1 - lights[i].brightness);
      else
        brightnesses.add(1.0);
    }
    map.putIfAbsent(this.name, () => brightnesses);
    return map;
  }

}
