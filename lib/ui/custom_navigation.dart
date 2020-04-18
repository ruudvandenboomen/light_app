import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomNavigation extends StatelessWidget {
  int _page;

  CustomNavigation(this._page);

  navigate(BuildContext context) {
    String routeName;
    if (this._page == 0) {
      routeName = '/lights';
    } else if (this._page == 1) {
      routeName = '/main';
    }

    Navigator.popUntil(context, (route) {
      if (route.settings.name != routeName) {
        Navigator.pushReplacementNamed(context, routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: this._page,
        onTap: (int index) {
          this._page = index;
          navigate(context);
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.toggleOn,
                color: Theme.of(context).accentColor),
            title: Text('Specific'),
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.lightbulb,
                color: Theme.of(context).accentColor),
            title: Text('Main control'),
          ),
        ]);
  }
}
