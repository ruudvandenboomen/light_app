import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:light_app/objects/room.dart';

class AddRoomPage extends StatefulWidget {
  final Room _room;

  AddRoomPage(this._room);

  @override
  State<StatefulWidget> createState() => AddRoomPageState();
}

class AddRoomPageState extends State<AddRoomPage> {
  @override
  void initState() {
    super.initState();
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add Room",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.arrowLeft,
              color: Theme.of(context).accentColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: 'Name'),
            ),
            Container(height: 20),
            FlatButton(
              padding: EdgeInsets.symmetric(vertical: 15),
              color: Theme.of(context).primaryColor,
              onPressed: () {},
              child: Text("ADD"),
            )
          ],
        ),
      ),
    );
  }
}
