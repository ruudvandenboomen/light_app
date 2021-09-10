import 'package:flutter/material.dart';
import 'package:light_app/objects/preset.dart';
import 'package:light_app/objects/temperature.dart';
import 'package:light_app/objects/light.dart';
import 'package:flutter/foundation.dart';

class Room extends ChangeNotifier {
  String name;
  List<Light> lights;
  List<Preset> presets = [];
  Preset presetInUse;
  Temperature _temperature;

  Room(this.name, this.lights);

  bool lightOn() {
    var lightOn = false;
    for (var light in lights) {
      if (light.brightness > 0) {
        lightOn = true;
        break;
      }
    }
    return lightOn;
  }

  Temperature get temperature => _temperature;

  set temperature(Temperature temperature) {
    _temperature = temperature;
    notifyListeners();
  }

  void setLightState(double brightness, bool turnedOn) {
    for (var light in lights) {
      light.turnedOn = turnedOn;
      light.brightness = brightness;
    }
  }

  double getAverageBrightness() {
    return lights.map((e) => e.brightness).reduce((a, b) => a + b) /
        lights.length;
  }

  void activatePreset(Preset preset) {
    for (var i = 0; i < lights.length; i++) {
      lights[i].brightness = preset.lights[i].brightness;
      lights[i].turnedOn = preset.lights[i].turnedOn;
    }
    presetInUse = preset;
  }

  void checkIfPresetIsActive() {
    presetInUse = null;
    for (var preset in presets) {
      if (listEquals(lights.map((light) => light.brightness).toList(),
          preset.lights.map((light) => light.brightness).toList())) {
        presetInUse = preset;
        notifyListeners();
      }
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    var brightnesses = <double>[];
    for (var i = 0; i < lights.length; i++) {
      var light = lights[i];
      if (light.turnedOn) {
        brightnesses
            .add(double.parse((lights[i].brightness).toStringAsFixed(2)));
      } else {
        brightnesses.add(0);
      }
    }
    map.putIfAbsent(name, () => brightnesses);
    return map;
  }

  void fromJson(Map<String, dynamic> json) {
    List<dynamic> brightnesses = json[name];
    for (var i = 0; i < lights.length; i++) {
      double brightness = brightnesses[i].toDouble();
      lights[i].brightness = brightness;
      lights[i].turnedOn = brightness > 0;
    }
    notifyListeners();
  }
}
