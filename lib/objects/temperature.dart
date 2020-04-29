class Temperature {
  double temperature;
  double humidity;
  double pressure;
  DateTime measured;

  Temperature(this.temperature, this.humidity);

  Temperature.fromJson(Map<String, dynamic> json)
      : temperature = json['temperature'],
        humidity = json['humidity'],
        pressure = json['pressure'],
        measured = DateTime.parse(json['measured']);
}
