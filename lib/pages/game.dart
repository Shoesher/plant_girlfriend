import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:plant_girlfriend/pages/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twine_parser/twine_parser.dart';
import 'package:plant_girlfriend/pages/Nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Game extends StatefulWidget {
  /// When opened through GameLoader these are already parsed, so the game
  /// starts instantly. When null, Game falls back to loading itself.
  final TwineParser? preloadedParser;
  final Passage? preloadedStart;

  const Game({super.key, this.preloadedParser, this.preloadedStart});

  @override
  State<Game> createState() => Game_();
}

class Game_ extends State<Game> {
  late final TwineParser parser;
  late Future<Passage> futurePassage;
  Passage? currentPassage;
  final Map<String, dynamic> gameState = {};
  File? curSprite;
  File? curBackground;
  int speed = 50;
  static double storyMood = 100;
  static double plantMood = 100;
  static double totalMood = (0.8 * plantMood) + (0.2 * storyMood);

  final ImageCache imageCache = PaintingBinding.instance.imageCache;

  final network mainNetwork = network();

  @override
  void initState() {
    super.initState();
    parser = widget.preloadedParser ?? TwineParser();
    // The app owns $mood; seed it before the story is parsed.
    gameState['mood'] = totalMood;
    futurePassage = getStartStory();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadData() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setDouble('mood', 100);
    preferences.setDouble('chapter', 0);
    preferences.setString('passage', (currentPassage ?? Passage(name: '', content: '', choices: [])).name);
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

            //Preload assets
            List parseList = parseAssets(currentPassage!.content);
            String spriteName = parseList[0];
            String backgroundName = parseList[1];
            String content = parseList[2];

            for (Choice choice in currentPassage!.choices) {

            // Precache the images of every passage reachable from here.
            for (Choice choice in currentPassage!.choices) {
              Passage passage = parser.getPassage(choice.targetPassage)!;
              List<String> list = parseAssets(passage.content);
              String sprite = list[0];
              String background = list[1];
              if (sprite.isNotEmpty)  {
                precacheImage(
                  
                  AssetImage('assets/PlantGirl_Images/$sprite'),
                 
                  context,
                  onError: (_, __) {},
                ,
                );
              }

              if (background.isNotEmpty) {
                precacheImage(
                  FileImage(File('assets/PlantGirl_Images/$background')),
                  context,
                );
              }
            }

            curSprite = spriteName.isNotEmpty
                ? File('assets/PlantGirl_Images/$spriteName')
                : curSprite;
            curBackground = backgroundName.isNotEmpty
                ? File('assets/Background_Images/$backgroundName')
                : curBackground;


            //Creating the Visual Novel environment
              if (background.isNotEmpty) {
                precacheImage(
                  AssetImage('assets/Background_Images/$background'),
                  context,
                  onError: (_, __) {},
                );
              }
            }

            curSprite = spriteName.isNotEmpty
                ? 'assets/PlantGirl_Images/$spriteName'
                : curSprite;
            curBackground = backgroundName.isNotEmpty
                ? 'assets/Background_Images/$backgroundName'
                : curBackground;

            return Stack(
              alignment: AlignmentGeometry.directional(0, 1),
              children: [
                Positioned(
                  left: 100,
                  child: Image.file(
                    curBackground ?? File('assets/Background_Images/'),
                if (curBackground != null)
                  Positioned(
                    left: 100,
                    child: Image.asset(
                      curBackground!,
                      errorBuilder: (context, error, stackTrace) => Container(),
                    ),
                  ),
                if (curSprite != null)
                  Image.asset(
                    curSprite!,
                    errorBuilder: (context, error, stackTrace) => Container(),
                  ),
                ),
                Image.file(
                  curSprite ?? File('assets/PlantGirl_Images/'),
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
                              border: currentPassage!.choices.isEmpty
                                  ? null
                                  : Border.all(
                                      color: const Color.fromARGB(
                                        255,
                                        60,
                                        105,
                                        70,
                                      ),
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
                Positioned(left: 0, top: 0, bottom: 0, child: globalNav()),
              ],
            );
          },
        ),
      ),
    );
  }


  /// First value returns the image url.
  /// Second value returns the rest of the content.
  List<String> parseAssets(String content) {
    // Extract text inside <>
    RegExp spriteRegex = RegExp(r'<(.*?)>');
    Match? spriteMatch = spriteRegex.firstMatch(content);
    String? spriteContent = spriteMatch?.group(
      1,
    ); // Gets the content on the inside of the <>

    RegExp bckgrndRegex = RegExp(r'\/(.*?)\/');
    Match? bckgrndMatch = bckgrndRegex.firstMatch(content);
    String? bckgrndContent = bckgrndMatch?.group(
      1,
    ); // Gets the content on the inside of the <>

    String rest = content.replaceAll(RegExp(r'<.*?>'), '');
    rest = rest.replaceAll(RegExp(r'\/.*?\/'), '').trim();

    List<String> result = [spriteContent ?? '', bckgrndContent ?? '', rest];

    return result;
  }

  Future<Passage> getStartStory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedPass = prefs.getString('currentPass') ?? 'Intro0';

    if (widget.preloadedStart != null) {
      currentPassage = widget.preloadedStart;
      return widget.preloadedStart!;
    }

    final storyHtml =
    await rootBundle.loadString('assets/PlantGirlTwine.html');

    await parser.parseStory(storyHtml);
    final start = parser.getSavedPassage(savedPass);
    final parsed = parser.getPassage(start.name, gameState: gameState) ?? start;
    if (parsed.stateChanges != null) gameState.addAll(parsed.stateChanges!);

    currentPassage = parsed;
    updateMood(100);

    return parsed;
  }

  Widget _buildTextBox() {
    return Container();
  }

  void updatePassage(String passageName) async {
    setState(() {
      final next = parser.getPassage(passageName, gameState: gameState);
      if (next?.stateChanges != null) gameState.addAll(next!.stateChanges!);
      currentPassage = next;
      imageCache.clear();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentPass', passageName);
  }

  /// Updates the app-owned mood value and re-evaluates the current passage so
  /// its conditionals and choices reflect the new value.
  void updateMood(num value) {
    setState(() {
      gameState['mood'] = value;
      if (currentPassage != null) {
        currentPassage = parser.getPassage(
          currentPassage!.name,
          gameState: gameState,
        );
      }
    });
  }

  Widget _buildChoices(List<Choice> choices) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
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
            Container()
          ],
        ),
      ),
    );
  }
}