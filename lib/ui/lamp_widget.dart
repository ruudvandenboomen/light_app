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
        int.parse((widget._lamp.getBrightness() * 10).toStringAsFixed(0)) * 100;
    if (colorIntensity < 100) {
      return 100;
    } else if (colorIntensity > 900) {
      return 900;
    }
    return colorIntensity;
  }

  Color getWidgetColor() {
    if (widget._lamp.isTurnedOn()) {
      return Colors.amberAccent[100];
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
        color: getWidgetColor(),
        child: Container(
            child: Stack(
          children: <Widget>[
            Positioned(
              left: 15,
              top: 40,
              child: Text(widget._lamp.getName(),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500)),
            ),
            Positioned(
                top: 0,
                right: 0,
                child: RotatedBox(
                    quarterTurns: 3,
                    child: CustomSwitch(
//                  activeColor: Colors.white,
                      value: widget._lamp.isTurnedOn(),
                      onChanged: (bool value) {
                        widget._lamp.setTurnedOn(value);
                        widget._sendMqttMessage();
                        setState(() {});
                      },
                    ))),
            Positioned(
              left: 15,
              top: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget._lamp.isTurnedOn() ? "AAN" : "UIT",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                      )),
                  Row(
                    children: <Widget>[
                      Text(
                          (widget._lamp.getBrightness() * 100)
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
              ),
            ),
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
                    if (widget._lamp.isTurnedOn()) {
                      widget._sendMqttMessage();
                    }
                  },
                  value: widget._lamp.getBrightness(),
                  onChanged: (brightness) {
                    widget._lamp.setBrightness(brightness);
                    setState(() {});
                  },
                ))
          ],
        )));
  }
}
