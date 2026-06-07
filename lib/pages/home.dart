// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_girlfriend/pages/Settings.dart';
import 'package:plant_girlfriend/pages/Network.dart';
import 'package:plant_girlfriend/pages/game.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  final network mainNetwork = network();
   int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    mainNetwork.connectSocket();
  }

  @override
  void dispose() {
    mainNetwork.disconnectSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 246, 234),
      body: Stack(
        children: [
          Column(
            children: [

              AppBar(
                title: const Text(
                  'Plant Girlfriend',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                  ),
                ),
                backgroundColor: const Color.fromARGB(255, 163, 255, 126),
                elevation: 0,
              ),
              Expanded(
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavbar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StreamBuilder<String>(
                              stream: mainNetwork.socketHandler.incomingMessagesStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  mainNetwork.parseSocket(snapshot.data!);
                                }
                                return Center(
                                  child: Column(
                                    children: [
                                      _buildBox('Brightness: ', mainNetwork.brightness + "%"),
                                      _buildBox('Humidity: ', mainNetwork.humidity + "%"),
                                      _buildBox('Temperature: ', mainNetwork.temperature + " °C"),
                                      _buildBox('Moisture: ', mainNetwork.moisture + "%")
                                    ],
                                  )
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            )
          ],
          ),         
        ],
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) { 
    return 
    NavigationRail( 
      extended: true, 
      minExtendedWidth: 100, 
      backgroundColor: const Color.fromARGB(255, 255, 238, 215), 
      selectedIndex: _selectedIndex, 
      indicatorColor: Color.fromARGB(0, 1, 1, 1), 
      //indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), 
      selectedIconTheme: IconThemeData(color: Color.fromARGB(0, 1, 1, 1), size: 60), 
      groupAlignment: 0.0,

      onDestinationSelected: (int index) {
      switch (index) {
        case 0: 
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
          break;
        case 1: 
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Game()));
          break;
        case 2: 
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings()));
          break;
        case 3: 
          //temp bcuz no store
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Game()));
          break;
        case 4: 
          exit(0);
      }
      setState(() => _selectedIndex = index);
    },

      destinations: const [ 
        NavigationRailDestination( 
          icon: SizedBox( width: 60, height: 60, child: Icon(Icons.home_filled, size: 60, color: Color.fromARGB(255, 87, 42, 0)), 
          
          ), 
          label: Text(''),
          padding: EdgeInsets.only(bottom: 60.0, left: 15),
        ), 
        NavigationRailDestination( 
          icon: SizedBox( width: 60, height: 60, child: Icon(Icons.videogame_asset, size: 60, color: Color.fromARGB(255, 87, 42, 0)), 
          
          ), 
          label: Text(''), 
          padding: EdgeInsets.only(bottom: 60.0, left: 15),
        ), 
        NavigationRailDestination( 
          icon: SizedBox( width: 60, height: 60, child: Icon(Icons.settings, size: 60, color: Color.fromARGB(255, 87, 42, 0)), 
          
          ), 
          label: Text(''), 
          padding: EdgeInsets.only(bottom: 60.0, left: 15),
        ), 
        NavigationRailDestination( 
          icon: SizedBox( width: 60, height: 60, child: Icon(Icons.store, size: 60, color: Color.fromARGB(255, 87, 42, 0)), 
          
          ), 
          label: Text(''), 
          padding: EdgeInsets.only(bottom: 60.0, left: 15),
        ), 
        NavigationRailDestination( 
          icon: SizedBox( width: 60, height: 60, child: Icon(Icons.exit_to_app, size: 60, color: Color.fromARGB(255, 87, 42, 0)), 
          
          ), 
          label: Text(''), 
          padding: EdgeInsets.only(bottom: 60.0, left: 15),
        ), 
      ], 
    ); 
  }

  Widget _buildBox(String title, String displayedValue) {
    return Container(
      width: 200.0,
      height: 150.0,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 204, 255, 202),
        borderRadius: BorderRadius.circular(20.0),
        
      ),       
      child: Column(
        children: <Widget>[
          Container(
            width: 200.0,
            height: 25.0,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 132, 180, 131),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                title
              )
            )     
          ),
          Center(
            child: Text(
              displayedValue,
              style: const TextStyle(
                color: Color.fromARGB(255, 122, 158, 117),
                fontWeight: FontWeight.bold,
                fontSize: 60,
              ),
            )
        )],
      )
    );
    
  }
}