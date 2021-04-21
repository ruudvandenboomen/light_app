import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color backgroundColor;

  CustomSwitch(
      {Key key,
      this.value,
      this.onChanged,
      this.backgroundColor = Colors.white})
      : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 60));
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (_animationController.isCompleted) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
            widget.value == false
                ? widget.onChanged(true)
                : widget.onChanged(false);
          },
          child: Container(
            width: 45.0,
            height: 26.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.0),
                color: widget.backgroundColor),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 2.0, bottom: 2.0, right: 4.0, left: 4.0),
              child: Container(
                alignment:
                    widget.value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18.0,
                  height: 18.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.value
                          ? Theme.of(context).accentColor
                          : Colors.grey[500]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
