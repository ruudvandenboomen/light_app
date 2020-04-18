class Secret {
  final String mqttHost;
  final String mqttUsername;
  final String mqttPassword;
  Secret({this.mqttHost = "", this.mqttUsername = "", this.mqttPassword = ""});
  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return new Secret(
        mqttHost: jsonMap["MQTT_HOST"],
        mqttUsername: jsonMap["MQTT_USERNAME"],
        mqttPassword: jsonMap["MQTT_PASSWORD"]);
  }
}
