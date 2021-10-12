import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

MqttClient makeClient(String url, String clientId, int port) =>
    MqttBrowserClient.withPort(url, clientId, port);
