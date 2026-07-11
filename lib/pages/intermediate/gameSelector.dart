// ignore_for_file: file_names, prefer_interpolation_to_compose_strings

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:plant_girlfriend/pages/Nav.dart';
import 'package:plant_girlfriend/pages/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameLoader extends StatefulWidget {
  const GameLoader({super.key});
  @override
  State<GameLoader> createState() => _GameLoaderState();
}
 
class _GameLoaderState extends State<GameLoader>{
  File loaderBg = File('assets/Background_Images/single_bedroom.jpg');
  double bgOffset = 100.0; //pixels
  List<String> greetings = ['I remember this', 'So many fun memories...', 'Back at it?', 'W rizz?'];
  List<String> backgrounds = ['bathroom.jpg', 'dining_kitchen.jpg', 'dining.jpg', 'entrance.jpg', 'hallway.jpg', 
    'kitchen.jpg', 'lounge.jpg', 'master_bedroom.jpg', 'outside1.jpg', 'outside2.jpg', 'single_bedroom.jpg'
  ];
  String? displayedPassage;
  List<int> hoverOpacities = [0,0,0];
  List<double> hoverRots = [0,0,0];
  List<String> cardFrames = [];
  //You can adapt this sprite based on the needed skin or character (After the shop feature)
  File plantSprite = File('assets/PlantGirl_Images/Idle_Pose.png'); 

  @override
  void initState(){
    super.initState();
    getPassageTitle();
    populateBackgrounds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Selector',
           style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 163, 255, 126),
        elevation: 0,
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: bgOffset,
            child: Image.file(loaderBg), 
          ),
        
            Positioned(
              right: 40,
              bottom: 1,
              child: Image.file(plantSprite),
            ), 
          
          Positioned(
            left: bgOffset + 40,
            top: 800,
            width: 260,
            child: buildPictureFrame(MaterialPageRoute(builder: (_) => const Game()), 'Branch', 2),
          ),
          Positioned(
            left: bgOffset + 40,
            top: 400,
            width: 260,
            child: buildPictureFrame(MaterialPageRoute(builder: (_) => const Game()), 'Replay', 1),
          ),
          Positioned(
            left: bgOffset + 40,
            top: 40,
            width: 260,
            child: buildPictureFrame(MaterialPageRoute(builder: (_) => const Game()), displayedPassage, 0),
          ),
          Positioned(left: 0, top: 0, bottom: 0, child: globalNav())
        ],
      )
    );
  }

  //Helpers
  Future<void> getPassageTitle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;          
    setState(() {
      displayedPassage = prefs.getString('currentPass') ?? 'New Game';
    });
  }

  void populateBackgrounds(){
    cardFrames.clear();
    for(int i=0; i<3; i++){
      int randomIndex = Random().nextInt(10);
      String frameBg = 'assets/Background_Images/' + backgrounds[randomIndex];
      cardFrames.add(frameBg);
    }
  }
  
  //Build assets

  Widget buildPictureFrame(MaterialPageRoute destination, String? cardTitle, int cardIndex) {
    //Selects a random bg out of laziness
    //You could make a map that connects each passage to a specific background if you wanted to
    File cardFrame = File(cardFrames[cardIndex]);

    return MouseRegion(
      onEnter:(event){
        setState(() => hoverOpacities[cardIndex] = 255);
        setState(() => hoverRots[cardIndex] = -0.2);
      },
      onExit:(event){ 
        setState(() => hoverOpacities[cardIndex] = 0);
        setState(() => hoverRots[cardIndex] = 0);
      },
      cursor: SystemMouseCursors.click, 
      
      child: 
        GestureDetector(
        onTap: () => Navigator.push(
          context,
          destination,
        ),
        child: 
          Card(
            color: Color.fromARGB(hoverOpacities[cardIndex], 85, 69, 69),
            child:
              Transform.rotate(
                angle: hoverRots[cardIndex],
                child: 
                  Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 110,
                        width: double.infinity,
                        child: Image.file(cardFrame, fit: BoxFit.cover),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          cardTitle ?? 'Loading…',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
    
  }
}