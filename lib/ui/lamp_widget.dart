import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:light_app/objects/light.dart';

import 'custom_switch.dart';

class LampWidget extends StatefulWidget {
  final Light _lamp;
  final VoidCallback _sendMqttMessage;

  LampWidget(this._lamp, this._sendMqttMessage);

  @override
  State<StatefulWidget> createState() => LampWidgetState();
}

class LampWidgetState extends State<LampWidget> {
  int getSliderColor() {
    var colorIntensity =
        int.parse((widget._lamp.brightness * 10).toStringAsFixed(0)) * 100;
    if (colorIntensity < 100) {
      return 100;
    } else if (colorIntensity > 900) {
      return 900;
    }
    return colorIntensity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 450,
        child: Card(
            margin: EdgeInsets.all(15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            color: Colors.white,
            child: Stack(
              children: <Widget>[
                Positioned(
                    left: 15,
                    top: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget._lamp.name,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 24.0,
                                fontWeight: FontWeight.w500)),
                        Container(
                          height: 10,
                        ),
                        Text(widget._lamp.turnedOn ? "AAN" : "UIT",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                            )),
                        Row(
                          children: <Widget>[
                            Text(
                                (widget._lamp.brightness * 100)
                                    .toStringAsFixed(0),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold)),
                            Text("%",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                )),
                          ],
                        )
                      ],
                    )),
                Positioned(
                    top: 0,
                    right: 0,
                    child: RotatedBox(
                        quarterTurns: 3,
                        child: CustomSwitch(
                          value: widget._lamp.turnedOn,
                          onChanged: (bool value) {
                            widget._lamp.turnedOn = value;
                            widget._sendMqttMessage();
                            this.setState(() {});
                          },
                        ))),
                Positioned.fill(
                    top: 90,
                    left: 0,
                    child: Slider(
                      divisions: 10,
                      inactiveColor: Colors.grey[100],
                      activeColor: Colors.amber[getSliderColor()],
                      min: 0.0,
                      max: 1.0,
                      onChangeEnd: (brightness) {
                        if (widget._lamp.turnedOn) {
                          widget._sendMqttMessage();
                        } else if (brightness > 0) {
                          widget._lamp.turnedOn = true;
                        }
                      },
                      value: widget._lamp.brightness,
                      onChanged: (brightness) {
                        widget._lamp.brightness = brightness;
                        setState(() {});
                      },
                    ))
              ],
            )));
  }
}
