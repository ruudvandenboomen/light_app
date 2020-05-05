import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomSlider extends StatelessWidget {
  final double totalWidth = 200.0;
  final double percentage;
  final Color positiveColor;
  final Color negativeColor;

  CustomSlider({this.percentage, this.positiveColor, this.negativeColor});

  @override
  Widget build(BuildContext context) {
    print((percentage / 100) * totalWidth);
    print((1 - percentage / 100) * totalWidth);
    return Container(
      width: totalWidth + 4.0,
      height: 30.0,
      decoration: BoxDecoration(
          color: negativeColor,
          border: Border.all(color: Colors.black, width: 2.0)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            color: positiveColor,
            width: (percentage / 100) * totalWidth,
          ),
        ],
      ),
    );
  }
}
