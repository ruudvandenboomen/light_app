import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:light_app/mqtt/mqtt_wrapper.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/ui/custom_scroll_behavior.dart';
import 'package:light_app/ui/lamp_widget.dart';

class OverviewPage extends StatefulWidget {
  final Room _room;
  final MQTTClientWrapper _mqttClientWrapper;

  OverviewPage(this._room, this._mqttClientWrapper);

  @override
  State<StatefulWidget> createState() => OverviewPageState();
}

class OverviewPageState extends State<OverviewPage> {
  @override
  void initState() {
    super.initState();
  }

  void update() {
    widget._mqttClientWrapper.publishMessage(jsonEncode(widget._room.toJson()));
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
          title: Text("Tune Lights",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: FaIcon(FontAwesomeIcons.arrowLeft,
                color: Theme.of(context).accentColor),
            onPressed: () => Navigator.pop(context),
          ),
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
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: widget._room.lights.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: (MediaQuery.of(context).size.width /
                              crossAxisCount /
                              widgetHeight),
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15),
                      itemBuilder: (BuildContext context, int index) {
                        return Center(
                            child: LampWidget(
                                widget._room.lights[index], () => update()));
                      },
                    ),
                  ),
                ),
              )),
            ]));
  }
}
