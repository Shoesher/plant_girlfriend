import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_girlfriend/pages/home.dart';
import 'package:plant_girlfriend/pages/game.dart';
import 'package:plant_girlfriend/pages/Settings.dart';

class globalNav extends StatelessWidget {
  const globalNav({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: true,
      minExtendedWidth: 100,
      backgroundColor: const Color.fromARGB(255, 255, 238, 215),
      selectedIndex: 0,
      indicatorColor: const Color.fromARGB(0, 1, 1, 1),
      selectedIconTheme: const IconThemeData(color: Color.fromARGB(0, 1, 1, 1), size: 60),
      groupAlignment: 0.0,
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const Home()));
            break;
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const Game()));
            break;
          case 2:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const Settings()));
            break;
          case 4:
            exit(0);
        }
      },
      destinations: const [
        NavigationRailDestination(
          icon: SizedBox(width: 60, height: 60, child: Icon(Icons.home_filled, size: 60, color: Color.fromARGB(255, 87, 42, 0))),
          label: Text(''),
          padding: EdgeInsets.only(bottom: 60.0, left: 15),
        ),
        NavigationRailDestination(
          icon: SizedBox(width: 60, height: 60, child: Icon(Icons.videogame_asset, size: 60, color: Color.fromARGB(255, 87, 42, 0))),
          label: Text(''),
          padding: EdgeInsets.only(bottom: 60.0, left: 15),
        ),
        NavigationRailDestination(
          icon: SizedBox(width: 60, height: 60, child: Icon(Icons.settings, size: 60, color: Color.fromARGB(255, 87, 42, 0))),
          label: Text(''),
          padding: EdgeInsets.only(bottom: 60.0, left: 15),
        ),
        NavigationRailDestination(
          icon: SizedBox(width: 60, height: 60, child: Icon(Icons.store, size: 60, color: Color.fromARGB(255, 87, 42, 0))),
          label: Text(''),
          padding: EdgeInsets.only(bottom: 60.0, left: 15),
        ),
        NavigationRailDestination(
          icon: SizedBox(width: 60, height: 60, child: Icon(Icons.exit_to_app, size: 60, color: Color.fromARGB(255, 87, 42, 0))),
          label: Text(''),
          padding: EdgeInsets.only(bottom: 60.0, left: 15),
        ),
      ],
    );
  }
}