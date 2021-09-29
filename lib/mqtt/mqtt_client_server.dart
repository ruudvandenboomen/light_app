import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient makeClient(String url, String clientId, int port) {
  var client = MqttServerClient.withPort(url, clientId, port);
  return client;
}
