import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:twine_parser/twine_parser.dart';
import 'package:plant_girlfriend/pages/Nav.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => Game_();
}

class Game_ extends State<Game> {
  final parser = TwineParser();
  late Future<Passage> futurePassage;
  Passage? currentPassage;
  int speed = 50;  

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
        child: FutureBuilder(
          future: futurePassage,

          builder: (build, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: const Color.fromARGB(255, 73, 163, 76),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Failed to load story \n ${snapshot.error}'),
              );
            }

            List parseList = parseImage(currentPassage!.content);
            String imgUrl = parseList[0];
            String content = parseList[1];

            return Stack(
              alignment: AlignmentGeometry.directional(0, 1),
              children: [
                Image.network(
                  imgUrl,
                  errorBuilder: (context, error, stackTrace) {
                    return Container();
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: SizedBox(
                      width: 1000,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: currentPassage!.choices.isEmpty ? null : Border.all(
                                color: const Color.fromARGB(255, 60, 105, 70),
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: _buildChoices(currentPassage!.choices),
                          ),
                          const SizedBox(height: 8),
                          DialogueBox(
                            speaker: 'Plant Chan',
                            text: content,
                            speed: speed,
                          ),
                          _speedUp(),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: globalNav(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// First value returns the image url.
  /// Second value returns the rest of the content.
  List<String> parseImage(String content) {
    // Extract text inside <>
    RegExp tagRegex = RegExp(r'<(.*?)>');
    Match? match = tagRegex.firstMatch(content);
    String? tagContent = match?.group(
      1,
    ); // Gets the content on the inside of the <>

    // Remove the <> and its contents from the string
    String rest = content.replaceAll(RegExp(r'\s*<.*?>\s'), '').trim();

    List<String> result = [tagContent ?? '', rest];

    return result;
  }

  Future<Passage> getStartStory() async {
    final storyHtml = await File('assets/PlantGirlTwine.html').readAsString();

    await parser.parseStory(storyHtml);
    final startPassage = parser.getStartPassage();

    currentPassage = startPassage;

    return startPassage;
  }

  Widget _buildTextBox() {
    return Container();
  }

  void updatePassage(String passageName) {
    setState(() {
      currentPassage = parser.getPassage(passageName);
    });
  }

  Widget _buildChoices(List<Choice> choices) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      // runSpacing: 10,
      // alignment: WrapAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: choices.map((choice) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 73, 129, 82),
          ),
          onPressed: () {
            updatePassage(choice.targetPassage);
          },
          child: Text(choice.text, style: TextStyle(color: Colors.white)),
        );
      }).toList(),
    );
  }

  Widget _speedUp() {
    return TextButton(
      child: Text('Speed Up'),
      onPressed: () => setState(() => speed = 20),
    );
  }
}

class DialogueBox extends StatefulWidget {
  final String speaker;
  final String text;
  final int speed;

  const DialogueBox({
    super.key,
    required this.speaker,
    required this.text,
    required this.speed,
  });

  @override
  State<DialogueBox> createState() => _DialogueBoxState();
}

class _DialogueBoxState extends State<DialogueBox> {
  String _displayed = '';
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void didUpdateWidget(DialogueBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _restart();
    } else if (oldWidget.speed != widget.speed) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _restart() {
    _displayed = '';
    _index = 0;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_index >= widget.text.length) return;
    _timer = Timer.periodic(Duration(milliseconds: widget.speed), (timer) {
      if (_index >= widget.text.length) {
        timer.cancel();
        return;
      }
      setState(() {
        _displayed += widget.text[_index];
        _index++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final boxHeight = 200.0;

    return Opacity(
      opacity: 1,
      child: Container(
        alignment: Alignment.bottomCenter,
        width: 1000,
        height: boxHeight,
        decoration: BoxDecoration(
          color: Color.fromARGB(190, 155, 255, 135),
          borderRadius: BorderRadiusGeometry.circular(20),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: boxHeight - 175,
              decoration: BoxDecoration(
                color: Color.fromARGB(197, 107, 150, 99),
              ),
              child: Padding(
                padding: EdgeInsetsGeometry.only(left: 10, top: 2, bottom: 2),
                child: Text(widget.speaker),
              ),
            ),
            Container(
              width: double.infinity,
              height: boxHeight - 25.0,
              decoration: BoxDecoration(),
              child: Padding(
                padding: EdgeInsetsGeometry.only(left: 10, top: 2, bottom: 2),
                child: Text(_displayed, style: TextStyle(fontSize: 25)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
