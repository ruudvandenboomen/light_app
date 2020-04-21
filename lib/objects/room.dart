import 'light.dart';

class Room {
  String _name;
  List<Light> _lights;

  Room(this._name, this._lights);

  String getName() {
    return this._name;
  }

  List<Light> getLights() {
    return this._lights;
  }

  bool lightOn() {
    bool lightOn = false;
    for (Light light in this._lights) {
      if (light.getBrightness() > 0) {
        lightOn = true;
        break;
      }
    }
    return lightOn;
  }

  setLightState(double brightness, bool turnedOn) {
    for (Light light in this._lights) {
      light.setTurnedOn(turnedOn);
      light.setBrightness(brightness);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    List<double> brightnesses = List();
    for (var i = 0; i < _lights.length; i++) {
      Light light = _lights[i];
      if (light.isTurnedOn())
        brightnesses.add(1 - _lights[i].getBrightness());
      else
        brightnesses.add(1.0);
    }
    map.putIfAbsent(this._name, () => brightnesses);
    return map;
  }

  double getAverageBrightness() {
    return this._lights.map((e) => e.getBrightness()).reduce((a, b) => a + b) /
        this._lights.length;
  }
}
