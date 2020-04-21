import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:light_app/mqtt/mqtt_wrapper.dart';
import 'package:light_app/objects/room.dart';
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
              Container(
                  child: Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: widget._room.getLights().length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (MediaQuery.of(context).orientation ==
                                Orientation.portrait)
                            ? 2
                            : 3),
                    itemBuilder: (BuildContext context, int index) {
                      int divideBy = MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? 2
                          : 3;
                      return Center(
                          child: LampWidget(
                              widget._room.getLights()[index], () => update()));
                    },
                  ),
                ),
              )),
            ]));
  }
}
