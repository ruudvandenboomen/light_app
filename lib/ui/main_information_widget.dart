import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:light_app/objects/room.dart';
import 'package:light_app/objects/temperature.dart';

import 'animated_count.dart';

class MainInformationWidget extends StatelessWidget {
  final Room room;
  final Temperature temperature;

  MainInformationWidget(this.room, this.temperature);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: <Widget>[
                  Flexible(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.lightbulb,
                                  color: Theme.of(context).colorScheme.secondary),
                              Container(
                                width: 5,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedCount(
                                      duration: Duration(seconds: 1),
                                      count: (room.getAverageBrightness() * 100)
                                          .toInt(),
                                      textStyle: TextStyle(fontSize: 40)),
                                  Text('%', style: TextStyle(fontSize: 18)),
                                ],
                              )
                            ],
                          ),
                        ],
                      )),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    child: VerticalDivider(
                      thickness: 1,
                    ),
                  ),
                  Flexible(
                      flex: 1,
                      child: temperature != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(FontAwesomeIcons.temperatureLow,
                                        color: Theme.of(context).colorScheme.secondary),
                                    Container(
                                      width: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          temperature.temperature.toStringAsFixed(0),
                                          style: TextStyle(fontSize: 40),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text('°C',
                                            style: TextStyle(fontSize: 18)),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            )
                          : Container()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
