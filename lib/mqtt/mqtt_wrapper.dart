import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/objects/temperature.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt_client_factory.dart';

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

  static const String lightTopic = 'home/summerhouse/lights';
  static const String temperatureTopic = 'home/summerhouse/temperature';

  String _server;
  String _clientId;
  int _port;
  String username;
  String password;
  BuildContext context;

  MqttClient client;

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
    if (kIsWeb) {
      client = makeClient('ws://127.0.0.1', _clientId, 8080);
    } else {
      client = makeClient(_server, _clientId, _port);
    }
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  Future<void> _connectClient() async {
    try {
      debugPrint('MQTTClientWrapper::Mosquitto client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;
      await client.connect(username, password);
    } on Exception catch (e) {
      debugPrint('MQTTClientWrapper::client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      debugPrint('MQTTClientWrapper::Mosquitto client connected');
    } else {
      debugPrint(
          'MQTTClientWrapper::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }

  void _subscribeToTopic(String topicName) {
    debugPrint('MQTTClientWrapper::Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final locationJson =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      debugPrint('MQTTClientWrapper::GOT A  MESSAGE $locationJson');
      _onMessageReceived(locationJson, c[0].topic);
    });
  }

  void _onMessageReceived(String message, String topic) {
    if (topic == MQTTClientWrapper.temperatureTopic) {
      Provider.of<Room>(context, listen: false).temperature =
          Temperature.fromJson(jsonDecode(message));
    } else if (topic == MQTTClientWrapper.lightTopic) {
      Provider.of<Room>(context, listen: false).fromJson(jsonDecode(message));
      Provider.of<Room>(context, listen: false).checkIfPresetIsActive();
    }
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    debugPrint(
        'MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
    onConnectedCallback();
  }

  void _onDisconnected() {
    debugPrint(
        'MQTTClientWrapper::OnDisconnected client callback - Client disconnection');
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
  }

  void _onSubscribed(String topic) {
    debugPrint('MQTTClientWrapper::Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  void publishMessage(String message,
      {String topic = MQTTClientWrapper.lightTopic}) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    if (connectionState == MqttCurrentConnectionState.DISCONNECTED) {
      _connectClient();
    }
    debugPrint('MQTTClientWrapper::Publishing message $message to topic');
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload,
        retain: true);
  }
}
