import 'package:flutter/material.dart';
import 'package:light_app/objects/preset.dart';
import 'package:light_app/objects/temperature.dart';
import 'package:light_app/objects/light.dart';

class Room extends ChangeNotifier {
  String name;
  List<Light> lights;
  List<Preset> presets = [];
  Preset presetInUse;
  Temperature _temperature;

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

  Temperature get temperature => this._temperature;

  set temperature(Temperature temperature) {
    this._temperature = temperature;
    notifyListeners();
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

  activatePreset(Preset preset) {
    for (int i = 0; i < this.lights.length; i++) {
      this.lights[i].brightness = preset.lights[i].brightness;
      this.lights[i].turnedOn = preset.lights[i].turnedOn;
    }
    this.presetInUse = preset;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    List<double> brightnesses = [];
    for (var i = 0; i < lights.length; i++) {
      Light light = lights[i];
      if (light.turnedOn)
        brightnesses
            .add(double.parse((lights[i].brightness).toStringAsFixed(2)));
      else
        brightnesses.add(0);
    }
    map.putIfAbsent(this.name, () => brightnesses);
    return map;
  }

  fromJson(Map<String, dynamic> json) {
    List<dynamic> brightnesses = json[name];
    for (var i = 0; i < lights.length; i++) {
      double brightness = brightnesses[i].toDouble();
      lights[i].brightness = brightness;
      lights[i].turnedOn = brightness > 0;
    }
    notifyListeners();
  }
}
