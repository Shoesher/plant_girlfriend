// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_girlfriend/pages/Settings.dart';
import 'package:plant_girlfriend/pages/Network.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  final network mainNetwork = network();
  bool _showSidebar = false;

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
                actions: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 40),
                    onPressed: () {
                      setState(() {
                        _showSidebar = !_showSidebar;
                      });
                    },
                  ),
                ],
              ),
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
          ),
          if (_showSidebar)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showSidebar = false;
                });
              },
              child: Container(
                // ignore: deprecated_member_use
                color: const Color.fromARGB(255, 135, 255, 131).withOpacity(0.5),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 0,
            bottom: 0,
            right: _showSidebar ? 0 : -250,
            child: _buildSideBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSideBar(BuildContext context) {
    return Container(
      width: 250,
      color: const Color.fromARGB(255, 30, 30, 30),
      child: Column(
        children: [
          const DrawerHeader(
            child: Text(
              'Options',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text('Settings', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Settings()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined, color: Colors.white),
            title: const Text('Docs', style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.white),
            title: const Text('Exit', style: TextStyle(color: Colors.white)),
            onTap: () => exit(0),
          ),
        ],
      ),
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