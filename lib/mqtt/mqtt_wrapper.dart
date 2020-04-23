import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

enum MqttCurrentConnectionState {
  IDLE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  ERROR_WHEN_CONNECTING
}
enum MqttSubscriptionState { IDLE, SUBSCRIBED }

class MQTTClientWrapper {
  static const String lightTopic = "home/summerhouse/lights";
  static const String temperatureTopic = "home/summerhouse/temperature";

  final String _server;
  final String _clientId;
  final int _port;
  String username;
  String password;

  MqttServerClient client;

  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  VoidCallback onConnectedCallback;
  Function(String, String) onMessageReceived;

  MQTTClientWrapper(this._server, this._clientId, this._port,
      this.onConnectedCallback, this.onMessageReceived,
      {this.username, this.password});

  void prepareMqttClient() async {
    _setupMqttClient();
    await _connectClient();
    _subscribeToTopic(MQTTClientWrapper.lightTopic);
    _subscribeToTopic(MQTTClientWrapper.temperatureTopic);
  }

  void _setupMqttClient() {
    client =
        MqttServerClient.withPort(this._server, this._clientId, this._port);
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  Future<void> _connectClient() async {
    try {
      print('MQTTClientWrapper::Mosquitto client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;
      await client.connect(this.username, this.password);
    } on Exception catch (e) {
      print('MQTTClientWrapper::client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      print('MQTTClientWrapper::Mosquitto client connected');
    } else {
      print(
          'MQTTClientWrapper::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }

  void _subscribeToTopic(String topicName) {
    print('MQTTClientWrapper::Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final String locationJson =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print("MQTTClientWrapper::GOT A  MESSAGE $locationJson");
      onMessageReceived(locationJson, topicName);
    });
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print(
        'MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
    onConnectedCallback();
  }

  void _onDisconnected() {
    print(
        'MQTTClientWrapper::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus.returnCode == MqttConnectReturnCode.solicited) {
      print(
          'MQTTClientWrapper::OnDisconnected callback is solicited, this is correct');
    }
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
  }

  void _onSubscribed(String topic) {
    print('MQTTClientWrapper::Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  void publishMessage(String message,
      {String topic = MQTTClientWrapper.lightTopic}) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    if (this.connectionState == MqttCurrentConnectionState.DISCONNECTED) {
      this._connectClient();
    }
    print('MQTTClientWrapper::Publishing message $message to topic');
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload);
  }
}
