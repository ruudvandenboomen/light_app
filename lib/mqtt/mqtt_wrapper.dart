import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/objects/temperature.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

enum MqttCurrentConnectionState {
  IDLE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  ERROR_WHEN_CONNECTING
}
enum MqttSubscriptionState { IDLE, SUBSCRIBED }

class MQTTClientWrapper {
  static final MQTTClientWrapper instance = MQTTClientWrapper._internal();

  static const String lightTopic = "home/summerhouse/lights";
  static const String temperatureTopic = "home/summerhouse/temperature";

  String _server;
  String _clientId;
  int _port;
  String username;
  String password;
  BuildContext context;

  MqttServerClient client;

  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  VoidCallback onConnectedCallback;

  factory MQTTClientWrapper(String server, String clientId, int port,
      VoidCallback onConnectedCallback, BuildContext context,
      {String username, String password}) {
    instance._server = server;
    instance._clientId = clientId;
    instance._port = port;
    instance.onConnectedCallback = onConnectedCallback;
    instance.context = context;
    instance.username = username;
    instance.password = password;
    instance.prepareMqttClient();
    return instance;
  }

  MQTTClientWrapper._internal();

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
      this._onMessageReceived(locationJson, c[0].topic);
    });
  }

  _onMessageReceived(String message, String topic) {
    if (topic == MQTTClientWrapper.temperatureTopic) {
      Provider.of<Room>(context, listen: false).temperature = Temperature.fromJson(jsonDecode(message));
    } else if (topic == MQTTClientWrapper.lightTopic) {
      Provider.of<Room>(context, listen: false).fromJson(jsonDecode(message));
    }
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
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload,
        retain: true);
  }
}
