import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:light_app/ui/round_slider_track_shape.dart';

import '../objects/room.dart';

class MainControlWidget extends StatefulWidget {
  Room room;
  double sliderValue;
  Function changeSliderValue;
  Function publishMqttMessage;

  MainControlWidget(this.room, this.sliderValue, this.changeSliderValue, this.publishMqttMessage);

  @override
  State<StatefulWidget> createState() => MainControlWidgetState();
}

class MainControlWidgetState extends State<MainControlWidget> {
  @override
  void initState() {
    super.initState();
    widget.sliderValue = widget.room.getAverageBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          child: Positioned.fill(
            top: 0,
            right: 0,
            child: RotatedBox(
              quarterTurns: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    height: 50,
                    child: SliderTheme(
                      data: Theme.of(context).sliderTheme.copyWith(
                            trackHeight: 50.0,
                            thumbShape:
                                RoundSliderThumbShape(enabledThumbRadius: 25),
                            trackShape: RoundSliderTrackShape(),
                            activeTrackColor: Colors.green,
                          ),
                      child: Slider(
                        divisions: 10,
                        inactiveColor: Colors.grey[100],
                        activeColor: Colors.amber[100],
                        min: 0.0,
                        max: 1.0,
                        onChangeEnd: (brightness) {
                          widget.changeSliderValue(brightness);
                        },
                        value: widget.sliderValue,
                        onChanged: (brightness) {
                          widget.changeSliderValue(brightness);
                          setState(() {});
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
            top: 20,
            left: 50,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("State", style: TextStyle(fontSize: 20)),
                Text(widget.room.lightOn() ? "ON" : "OFF",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      color: widget.room.lightOn()
                          ? Colors.amber[200]
                          : Colors.grey,
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FaIcon(FontAwesomeIcons.solidSun, color: Colors.amber[200]),
                    Container(
                      width: 5,
                    ),
                    Text((widget.sliderValue * 100).toStringAsFixed(0),
                        style: TextStyle(
                            fontSize: 50, fontWeight: FontWeight.bold)),
                    Text("%", style: TextStyle(fontSize: 24))
                  ],
                ),
                Container(
                  height: 20,
                ),
                RaisedButton(
                    color: Colors.amber[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
                    child: Text("TURN ON"),
                    onPressed: () {
                      widget.room.setLightState(widget.sliderValue, true);
                      widget
                          .publishMqttMessage(jsonEncode(widget.room.toJson()));
                      setState(() {});
                    }),
                Container(
                  height: 20,
                ),
                RaisedButton(
                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
                    child: Text("TURN OFF"),
                    onPressed: () {
                      widget.room.setLightState(0.0, false);
                      widget.sliderValue = 0;
                      widget
                          .publishMqttMessage(jsonEncode(widget.room.toJson()));
                      setState(() {});
                    }),
                Container(
                  height: 20,
                ),
                RaisedButton(
                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
                    child: Text(
                      "TUNE LIGHTS",
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/lights");
                    })
              ],
            )),
      ],
    );
  }
}
