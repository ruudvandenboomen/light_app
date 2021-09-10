import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:light_app/objects/light.dart';

import 'custom_switch.dart';

class LampWidget extends StatefulWidget {
  final Light _lamp;
  final VoidCallback _sendMqttMessage;

  const LampWidget(this._lamp, this._sendMqttMessage);

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
    return SizedBox(
        height: 450,
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget._lamp.name,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500)),
                        CustomSwitch(
                          value: widget._lamp.turnedOn,
                          backgroundColor: Colors.grey[100],
                          onChanged: (bool value) {
                            if (!widget._lamp.turnedOn && value) {
                              widget._lamp.brightness = 0.5;
                            }
                            if (!value) {
                              widget._lamp.brightness = 0;
                            }
                            widget._lamp.turnedOn = value;
                            widget._sendMqttMessage();
                            setState(() {});
                          },
                        ),
                      ]),
                ),
                Container(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(widget._lamp.turnedOn ? 'AAN' : 'UIT',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                      )),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: <Widget>[
                      Text((widget._lamp.brightness * 100).toStringAsFixed(0),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold)),
                      Text('%',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                          )),
                    ],
                  ),
                ),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Slider(
                      divisions: 10,
                      inactiveColor: Colors.grey[100],
                      activeColor: Colors.green[200],
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
                    )),
              ],
            )));
  }
}
