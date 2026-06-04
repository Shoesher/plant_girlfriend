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
  late Future<Passage> futurePassage;
  Passage? currentPassage;

  @override
  void initState() {
    super.initState();
    futurePassage = getStartStory();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder(future: futurePassage,

        builder: (build, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(color: const Color.fromARGB(255, 73, 163, 76),),
            );
          }

          if (snapshot.hasError){
            return Center(
              child: Text('Failed to load story \n ${snapshot.error}'),
            );
          }

          return 
          Align(
            alignment: Alignment(0, 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: AlignmentGeometry.xy(0.6, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color.fromARGB(255, 60, 105, 70), width: 3),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: _buildChoices(currentPassage!.choices),
                  )
                ),
                const SizedBox(height: 2),
                Align(
                  child: DialogueBox(speaker: 'Plant Chan', text: currentPassage!.content),
                ),
                _speedUp()
              ],
            )
          );
        }),
      )
    );
  }
  

  Future<Passage> getStartStory() async{
    final storyHtml = await File('assets/PlantGirlTwine.html').readAsString();

    await parser.parseStory(storyHtml);
    final startPassage = parser.getStartPassage();
    
    currentPassage = startPassage;

    return startPassage;
  }

  Widget _buildTextBox(){
    return Container();
  }

  void updatePassage(String passageName){
    setState(() {
      currentPassage = parser.getPassage(passageName);
    });
  }

  Widget _buildChoices(List<Choice> choices){
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,

      children: 
        choices.map((choice) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 73, 129, 82)
            ),
            onPressed: () => updatePassage(choice.targetPassage), 
            child: Text(
              choice.text,
              style: TextStyle(color: Colors.white),
            )
          );
        }
      ).toList()
    );
  }

  Widget _speedUp() {
        return TextButton(
          child: Text('Speed Up'),
          onPressed: () => DialogueBox.speed = 45);
  }
}

class DialogueBox extends StatelessWidget{
  final String speaker;
  final String text;
  String currentText = "";
  static int speed = 70;

  DialogueBox({super.key, required this.speaker, required this.text});

  Stream<String> _getTextStream(String fullPassage) async* {
    for(int i=0; i < fullPassage.length; i++){
      await Future.delayed(Duration(milliseconds: speed));
      String currentChar = fullPassage[i];
      yield currentChar;
    }
    yield ' ';
  }

  late final Stream<String> textStream = _getTextStream(text);

  @override
  Widget build(BuildContext context) {
    final boxHeight = 200.0;

    return 
    Opacity(
      opacity: 1,
      child: 
      Container(
        alignment: Alignment.bottomCenter,
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
                child: StreamBuilder<String>(
                          stream: textStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              currentText += snapshot.requireData;
                              return Text(
                                currentText,
                                style: TextStyle(fontSize: 25)
                              );
                            }
                            else{
                              return Text(
                              'Error, Stream not found', 
                              style: TextStyle(fontSize: 25)
                            );
                            }
                          },
                        ),
              ),
            )
          ],
        ),
      )
    );
  }
  
}