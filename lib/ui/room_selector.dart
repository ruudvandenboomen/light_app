import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:light_app/objects/room.dart';

class RoomSelectorWidget extends StatefulWidget {
  final Room _room;
  final Room _currentRoom;
  final Function _changeCurrentRoom;

  const RoomSelectorWidget(
      this._room, this._currentRoom, this._changeCurrentRoom);

  @override
  State<StatefulWidget> createState() => RoomSelectorWidgetState();
}

class RoomSelectorWidgetState extends State<RoomSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    var isSelected = widget._room == widget._currentRoom;
    return GestureDetector(
        onTap: () {
          widget._changeCurrentRoom(widget._room);
        },
        child: Card(
            elevation: isSelected ? 2 : 1,
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0)),
            child: Stack(
              children: <Widget>[
                Container(
                    width: 140,
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Text(
                      widget._room.name,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.black : Colors.grey),
                    ))
              ],
            )));
  }
}
