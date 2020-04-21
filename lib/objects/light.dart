class Light {
  String _name;
  bool _turnedOn = false;
  double _brightness = 0.0;

  Light(this._name);

  String getName() {
    return this._name;
  }

  bool isTurnedOn() {
    return this._turnedOn;
  }

  void setTurnedOn(bool value) {
    this._turnedOn = value;
  }

  double getBrightness() {
    return this._brightness;
  }

  setBrightness(double brightness) {
    this._brightness = brightness;
  }

}
