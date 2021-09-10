import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:light_app/mqtt/mqtt_wrapper.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/ui/custom_scroll_behavior.dart';
import 'package:light_app/ui/lamp_widget.dart';
import 'package:provider/provider.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage();

  @override
  State<StatefulWidget> createState() => OverviewPageState();
}

class OverviewPageState extends State<OverviewPage> {
  MQTTClientWrapper mqttClientWrapper;
  @override
  void initState() {
    super.initState();
    mqttClientWrapper = MQTTClientWrapper.instance;
  }

  void update() {
    mqttClientWrapper.publishMessage(
        jsonEncode(Provider.of<Room>(context, listen: false).toJson()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var crossAxisCountLandscape =
        MediaQuery.of(context).size.width > 800 ? 4 : 3;
    var crossAxisCount =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? 2
            : crossAxisCountLandscape;
    var widgetHeight = 220;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Tune Lights',
              style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'Ubuntu',
                  color: Colors.green[300],
                  fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                  child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ScrollConfiguration(
                      behavior: CustomScrollBehavior(),
                      child: Consumer<Room>(builder: (context, room, child) {
                        return GridView.builder(
                          shrinkWrap: true,
                          itemCount: room.lights.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio:
                                      (MediaQuery.of(context).size.width /
                                          crossAxisCount /
                                          widgetHeight),
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15),
                          itemBuilder: (BuildContext context, int index) {
                            return Center(
                                child: LampWidget(
                                    room.lights[index], () => update()));
                          },
                        );
                      })),
                ),
              )),
            ]));
  }
}
