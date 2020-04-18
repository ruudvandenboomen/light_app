import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainControlWidget extends StatefulWidget {
  double sliderValue;
  Function changeSliderValue;

  MainControlWidget(this.sliderValue, this.changeSliderValue);

  @override
  State<StatefulWidget> createState() => MainControlWidgetState();
}

class MainControlWidgetState extends State<MainControlWidget> {
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
                            height: 45,
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
                            ))
                      ],
                    ))))
      ],
    );
  }
}
