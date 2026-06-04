import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:twine_parser/twine_parser.dart';


class Game extends StatefulWidget {
    const Game({super.key});
    
      @override
      State<Game> createState() => Game_();
}

class Game_ extends State<Game>{
  final parser = TwineParser();
  Passage curPass = Passage(name: '', content: '', choices: []);
  StreamController<Passage> passageController = StreamController<Passage>.broadcast();
  Stream<Passage> get newPassageStream => passageController.stream;

  @override
  void initState() {
    super.initState();
    getStartStory().then((passage) => curPass = passage);
    passageController.add(curPass);
  }

  @override
  void dispose() {
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: StreamBuilder(
          stream: passageController.stream, 
          builder: (context, snapshot){
              if(snapshot.hasData){
                print("checkpoint");
                curPass = snapshot.data ?? Passage(name: 'error', content: 'error', choices: []);
              }

              return DialogueBox(speaker: 'test', text: curPass.content);
          }
        )
      )
    );
  }
  

  Future<Passage> getStartStory() async{
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;

    final storyHtml = await File('$path/PlantGirlTwine.html').readAsString();

    await parser.parseStory(storyHtml);
    final startPassage = parser.getStartPassage();
    
    return startPassage;
  }

  Future<String> get _localPath async{
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Widget _buildTextBox(){
    return Container();
  }

  Widget _buildChoices(){
    return Container();
  }
}

class DialogueBox extends StatelessWidget{
  final String speaker;
  final String text;

  const DialogueBox({super.key, required this.speaker, required this.text});

  @override
  Widget build(BuildContext context) {
    final boxHeight = 200.0;

    return 
    Opacity(
      opacity: 1,
      child: 
      Container(
        width: 1000,
        height: boxHeight,
        decoration: BoxDecoration(
          color: Color.fromARGB(190, 155, 255, 135),
          borderRadius: BorderRadiusGeometry.circular(20)
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: boxHeight - 175,
              decoration: BoxDecoration(
                color: Color.fromARGB(197, 107, 150, 99)
              ),
              child: Padding(
                padding: EdgeInsetsGeometry.only(left: 10, top: 2, bottom: 2),
                child: Text(speaker)
              ),
            ),
            Container(
              width: double.infinity,
              height: boxHeight - 25.0,
              decoration: BoxDecoration(
                
              ),
              child: Padding(
                padding: EdgeInsetsGeometry.only(left: 10, top: 2, bottom: 2),
                child: Text(
                  text, 
                  style: TextStyle(fontSize: 25)
                )
              ),
            )
          ],
        ),
      )
    );
  }
  
}