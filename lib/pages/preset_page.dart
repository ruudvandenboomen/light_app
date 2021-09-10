import 'package:flutter/material.dart';
import 'package:light_app/objects/preset.dart';
import 'package:light_app/ui/custom_scroll_behavior.dart';
import 'package:light_app/ui/lamp_widget.dart';

class PresetPage extends StatefulWidget {
  final Preset _preset;

  const PresetPage(this._preset);

  @override
  _PresetPageState createState() => _PresetPageState();
}

class _PresetPageState extends State<PresetPage> {
  @override
  void initState() {
    super.initState();
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var crossAxisCountLandscape =
        MediaQuery.of(context).size.width > 800 ? 4 : 3;
    var crossAxisCount =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? 2
            : crossAxisCountLandscape;
    var widgetHeight = 220;

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pop(context, widget._preset),
          foregroundColor: Colors.white,
          child: Icon(Icons.save),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: Text('Presets instellen',
              style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'Ubuntu',
                  color: Colors.green[300],
                  fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Container(
            margin: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text('Naam', style: TextStyle(fontSize: 18)),
                  TextFormField(
                    initialValue: widget._preset.name,
                    onChanged: (text) {
                      widget._preset.name = text;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.green[300], width: 1)),
                        hintStyle: TextStyle()),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  Container(height: 15),
                  Divider(
                    thickness: 1,
                  ),
                  Container(height: 10),
                  Expanded(
                      child: Container(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ScrollConfiguration(
                        behavior: CustomScrollBehavior(),
                        child: GridView.builder(
                          padding: EdgeInsets.only(bottom: 50),
                          shrinkWrap: true,
                          itemCount: widget._preset.lights.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio:
                                      (MediaQuery.of(context).size.width /
                                          crossAxisCount /
                                          widgetHeight),
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15),
                          itemBuilder: (BuildContext context, int index) {
                            return Center(
                                child: LampWidget(widget._preset.lights[index],
                                    () => update()));
                          },
                        ),
                      ),
                    ),
                  )),
                ])));
  }
}
