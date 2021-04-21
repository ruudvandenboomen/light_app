class Light {
  int id;
  String name;
  bool turnedOn = false;
  double brightness = 0.0;

  Light(this.name);

  Light.fromDB(this.id, this.name, this.brightness, this.turnedOn);

  Map<String, dynamic> toMap(presetId) {
    return {
      'name': name,
      'turnedOn': turnedOn ? 1 : 0,
      'brightness': brightness,
      'preset_id': presetId,
    };
  }
}
