import 'room.dart';
import 'light.dart';

class Preset {
  int id;
  String name;
  List<Light> lights = [];

  Preset(this.name, Room room) {
    room.lights.forEach((light) {
      this.lights.add(Light(light.name));
    });
  }

  Preset.fromDB(this.id, this.name, this.lights);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}
