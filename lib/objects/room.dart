import 'light.dart';

class Room {
  String _name;
  List<Light> _lights;

  Room(this._name, this._lights);

  getName() {
    return this._name;
  }

  getLights() {
    return this._lights;
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
}
