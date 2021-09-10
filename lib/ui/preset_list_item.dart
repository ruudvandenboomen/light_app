import 'package:flutter/material.dart';
import 'package:light_app/objects/preset.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/pages/preset_page.dart';
import 'package:light_app/util/database_service.dart';

import 'custom_switch.dart';

class PresetListItem extends StatefulWidget {
  final Preset preset;
  final Room room;
  final VoidCallback update;

  PresetListItem(this.preset, this.room, this.update);

  @override
  _PresetListItemState createState() => _PresetListItemState();
}

class _PresetListItemState extends State<PresetListItem> {
  DatabaseService dbService = DatabaseService();

  void _editPresetPage(BuildContext context) async {
    // start the SecondScreen and wait for it to finish with a result
    var editedPreset = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PresetPage(widget.preset),
        ));
    if (editedPreset != null) {
      await dbService.updatePreset(editedPreset);
    }
    widget.update();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60,
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.all(Radius.circular(15))),
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Row(children: [
          Container(
            width: 120,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              widget.preset.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18),
            ),
          ),
          IconButton(
              color: Colors.green[300],
              padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
              constraints: BoxConstraints(),
              icon: Icon(Icons.edit),
              onPressed: () {
                _editPresetPage(context);
              }),
          IconButton(
              color: Colors.green[300],
              padding: EdgeInsets.fromLTRB(5, 0, 10, 0),
              constraints: BoxConstraints(),
              icon: Icon(Icons.delete),
              onPressed: () async {
                await dbService.deletePreset(widget.preset.id);
                widget.room.presets.remove(widget.preset);
                widget.update();
              }),
          Spacer(),
          CustomSwitch(
              onChanged: (bool value) {
                if (value == true) {
                  widget.room.activatePreset(widget.preset);
                } else {
                  widget.room.presetInUse = null;
                  widget.room.setLightState(0, false);
                }
                widget.update();
              },
              value: widget.room.presetInUse == widget.preset)
        ]));
  }
}
