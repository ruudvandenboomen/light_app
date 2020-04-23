class Temperature {
  double temperature;
  double humidity;
  double pressure;

  Temperature(this.temperature, this.humidity);

  Temperature.fromJson(Map<String, dynamic> json)
      : temperature = json['temperature'],
        humidity = json['humidity'],
        pressure = json['pressure'];
}
