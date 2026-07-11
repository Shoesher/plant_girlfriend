// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:plant_girlfriend/pages/settings.dart';
import 'package:plant_girlfriend/pages/Network.dart';
import 'package:plant_girlfriend/pages/intermediate/gameSelector.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

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
      body: Column(
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNavbar(context),

                // ----- Stat bars -----
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: StreamBuilder<String>(
                        stream:
                            mainNetwork.socketHandler.incomingMessagesStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            mainNetwork.parseSocket(snapshot.data!);
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 12.0),
                                child: Text(
                                  'Plant Chan Stats',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 87, 42, 0),
                                  ),
                                ),
                              ),
                              _buildStatBar(
                                title: 'Brightness',
                                icon: Icons.wb_sunny,
                                rawValue: mainNetwork.brightness,
                                unit: '%',
                              ),
                              _buildStatBar(
                                title: 'Humidity',
                                icon: Icons.water_drop,
                                rawValue: mainNetwork.humidity,
                                unit: '%',
                              ),
                              _buildStatBar(
                                title: 'Temperature',
                                icon: Icons.thermostat,
                                rawValue: mainNetwork.temperature,
                                unit: ' \u00b0C',
                                maxValue: 40, // bar is full at 40 degrees
                              ),
                              _buildStatBar(
                                title: 'Moisture',
                                icon: Icons.grass,
                                rawValue: mainNetwork.moisture,
                                unit: '%',
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ----- 3D character viewer -----
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 234, 255, 226),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color.fromARGB(255, 132, 180, 131),
                        width: 2,
                      ),
                    ),
                    child: ModelViewer(
                      // On web the src is a browser URL and Flutter serves
                      // bundled assets under assets/<asset-key>, so the key
                      // 'assets/Plant_Girl.glb' lives at assets/assets/....
                      src: kIsWeb
                          ? 'assets/assets/Plant_Girl.glb'
                          : 'assets/Plant_Girl.glb',
                      alt: 'Plant Chan',
                      autoPlay: true,
                      autoRotate: true,
                      autoRotateDelay: 0,
                      rotationPerSecond: '25deg',
                      ar: false,
                      cameraControls: true,
                      disableZoom: true,
                      disablePan: true,
                      disableTap: true,
                      cameraOrbit: '0deg 90deg auto',
                      fieldOfView: '30deg',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar({
    required String title,
    required IconData icon,
    required String rawValue,
    required String unit,
    double maxValue = 100,
  }) {
    final double? parsed = double.tryParse(rawValue);
    final bool hasData = parsed != null;
    final double fraction =
        hasData ? (parsed / maxValue).clamp(0.0, 1.0) : 0.0;

    // Red when low, yellow in the middle, green when high.
    final Color barColor = Color.lerp(
      Color.lerp(const Color(0xFFE57373), const Color(0xFFFFD54F),
          (fraction * 2).clamp(0.0, 1.0))!,
      const Color(0xFF66BB6A),
      ((fraction - 0.5) * 2).clamp(0.0, 1.0),
    )!;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 204, 255, 202),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: const Color.fromARGB(255, 87, 42, 0)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 87, 42, 0),
                ),
              ),
              const Spacer(),
              Text(
                hasData ? '$rawValue$unit' : rawValue,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: hasData
                      ? const Color.fromARGB(255, 122, 158, 117)
                      : Colors.grey,
                ),
              ),
              const SizedBox(width: 10),
              _buildGradeBadge(fraction, hasData),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: fraction),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, animatedFraction, _) {
                return Stack(
                  children: [
                    Container(
                      height: 18,
                      color: const Color.fromARGB(255, 236, 245, 230),
                    ),
                    FractionallySizedBox(
                      widthFactor: animatedFraction,
                      child: Container(height: 18, color: barColor),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeBadge(double fraction, bool hasData) {
    String grade;
    if (!hasData) {
      grade = '-';
    } else if (fraction >= 0.9) {
      grade = 'S';
    } else if (fraction >= 0.7) {
      grade = 'A';
    } else if (fraction >= 0.5) {
      grade = 'B';
    } else if (fraction >= 0.3) {
      grade = 'C';
    } else {
      grade = 'D';
    }

    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 132, 180, 131),
        shape: BoxShape.circle,
      ),
      child: Text(
        grade,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    return NavigationRail(
      extended: true,
      minExtendedWidth: 100,
      backgroundColor: const Color.fromARGB(255, 255, 238, 215),
      selectedIndex: _selectedIndex,
      indicatorColor: const Color.fromARGB(0, 1, 1, 1),
      selectedIconTheme:
          const IconThemeData(color: Color.fromARGB(0, 1, 1, 1), size: 60),
      groupAlignment: 0.0,
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            break; // already home
          case 1:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const GameLoader()));
            break;
          case 2:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Settings()));
            break;
          case 3:
            // temp bcuz no store
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const GameLoader()));
            break;
          case 4:
            SystemNavigator.pop();
        }
        setState(() => _selectedIndex = index);
      },
      destinations: const [
        NavigationRailDestination(
          icon: SizedBox(
            width: 60,
            height: 60,
            child: Icon(Icons.home_filled,
                size: 60, color: Color.fromARGB(255, 87, 42, 0)),
          ),
          label: Text(''),
          padding: EdgeInsets.only(bottom: 60.0, left: 15),
        ),
        NavigationRailDestination(
          icon: SizedBox(
            width: 60,
            height: 60,
            child: Icon(Icons.videogame_asset,
                size: 60, color: Color.fromARGB(255, 87, 42, 0)),
          ),
          label: Text(''),
          padding: EdgeInsets.only(bottom: 60.0, left: 15),
        ),
        NavigationRailDestination(
          icon: SizedBox(
            width: 60,
            height: 60,
            child: Icon(Icons.settings,
                size: 60, color: Color.fromARGB(255, 87, 42, 0)),
          ),
          label: Text(''),
          padding: EdgeInsets.only(bottom: 60.0, left: 15),
        ),
        NavigationRailDestination(
          icon: SizedBox(
            width: 60,
            height: 60,
            child: Icon(Icons.store,
                size: 60, color: Color.fromARGB(255, 87, 42, 0)),
          ),
          label: Text(''),
          padding: EdgeInsets.only(bottom: 60.0, left: 15),
        ),
        NavigationRailDestination(
          icon: SizedBox(
            width: 60,
            height: 60,
            child: Icon(Icons.exit_to_app,
                size: 60, color: Color.fromARGB(255, 87, 42, 0)),
          ),
          label: Text(''),
          padding: EdgeInsets.only(bottom: 60.0, left: 15),
        ),
      ],
    );
  }
}