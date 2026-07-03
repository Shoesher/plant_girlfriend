import 'dart:async';
import 'dart:math';
 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twine_parser/twine_parser.dart';
import 'package:plant_girlfriend/pages/game.dart';
 
/// Umamusume-style loading screen.
///
/// Shows a bouncing chibi, a "Now Loading..." pulse, a progress bar with a
/// little runner icon that travels along it, and a random gameplay tip.
/// While the animation plays it does REAL work: it loads and parses the
/// Twine story and precaches the first images, then hands the parsed story
/// to [Game] so the game itself opens instantly.
class GameLoader extends StatefulWidget {
  const GameLoader({super.key});
 
  @override
  State<GameLoader> createState() => _GameLoaderState();
}
 
class _GameLoaderState extends State<GameLoader>
    with TickerProviderStateMixin {
  final TwineParser _parser = TwineParser();
 
  double _progress = 0.0;
  String _status = 'Now Loading...';
  bool _failed = false;
  String _errorMessage = '';
 
  late final String _tip;
  late final AnimationController _bounceController;
  late final AnimationController _pulseController;
 
  static const List<String> _tips = [
    'Tip: Water Plant Chan regularly - moisture below 30% makes her sad!',
    'Tip: Bright light boosts her mood. Keep brightness above 60%!',
    'Tip: Plant Chan likes it cozy - around 20-25 \u00b0C is perfect.',
    'Tip: Your choices in the story change how Plant Chan feels about you.',
    'Tip: Use the Speed Up button if the dialogue is too slow for you.',
    'Tip: Check the Home page to see live sensor stats from your real plant!',
  ];
 
  @override
  void initState() {
    super.initState();
    _tip = _tips[Random().nextInt(_tips.length)];
 
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..repeat(reverse: true);
 
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
 
    _startLoading();
  }
 
  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
 
  void _setProgress(double value, String status) {
    if (!mounted) return;
    setState(() {
      _progress = value;
      _status = status;
    });
  }
 
  Future<void> _startLoading() async {
    // Keeps the loader on screen at least this long so it doesn't flash by.
    final Future<void> minDisplayTime =
        Future.delayed(const Duration(milliseconds: 2200));
 
    try {
      _setProgress(0.15, 'Watering the story...');
      // rootBundle works on web, desktop, and mobile (dart:io File does NOT
      // work on web). The file must be declared under assets: in pubspec.yaml.
      final String storyHtml =
          await rootBundle.loadString('assets/PlantGirlTwine.html');
 
      _setProgress(0.45, 'Growing dialogue trees...');
      await _parser.parseStory(storyHtml);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String savedPass = prefs.getString('currentPass') ?? 'Intro0';
      final Passage startPassage = _parser.getStartPassage(savedPass);
 
      _setProgress(0.75, 'Waking up Plant Chan...');
      await _precachePassageImages(startPassage);
 
      _setProgress(0.95, 'Almost there...');
      await minDisplayTime;
 
      _setProgress(1.0, 'Ready!');
      await Future.delayed(const Duration(milliseconds: 350));
 
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Game(
            preloadedParser: _parser,
            preloadedStart: startPassage,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _errorMessage = e.toString();
      });
    }
  }
 
  /// Precaches the sprite/background of a passage so the first game frame
  /// doesn't pop in. Uses the same <sprite> and /background/ markup that
  /// game.dart parses.
  Future<void> _precachePassageImages(Passage passage) async {
    final String? sprite =
        RegExp(r'<(.*?)>').firstMatch(passage.content)?.group(1);
    final String? background =
        RegExp(r'\/(.*?)\/').firstMatch(passage.content)?.group(1);
 
    if (!mounted) return;
    final List<Future<void>> jobs = [];
    if (sprite != null && sprite.isNotEmpty) {
      jobs.add(precacheImage(
        AssetImage('assets/PlantGirl_Images/$sprite'),
        context,
        onError: (_, __) {}, // missing image shouldn't kill the loader
      ));
    }
    if (background != null && background.isNotEmpty) {
      jobs.add(precacheImage(
        AssetImage('assets/Background_Images/$background'),
        context,
        onError: (_, __) {},
      ));
    }
    await Future.wait(jobs);
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 213, 255, 190),
              Color.fromARGB(255, 255, 246, 234),
            ],
          ),
        ),
        child: Center(
          child: _failed ? _buildError() : _buildLoading(),
        ),
      ),
    );
  }
 
  Widget _buildLoading() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBouncingMascot(),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: Tween<double>(begin: 0.35, end: 1.0)
                  .animate(_pulseController),
              child: const Text(
                'Now Loading...',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 87, 42, 0),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _status,
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 122, 158, 117),
              ),
            ),
            const SizedBox(height: 28),
            _buildProgressBar(),
            const SizedBox(height: 40),
            _buildTipCard(),
          ],
        ),
      ),
    );
  }
 
  Widget _buildBouncingMascot() {
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -14 * _bounceController.value),
          child: child,
        );
      },
      // Tries to show a chibi sprite; falls back to a flower icon if the
      // file isn't there (rename to whatever sprite you want to use).
      child: SizedBox(
        height: 140,
        child: Image.asset(
          'assets/PlantGirl_Images/chibi.png',
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.local_florist,
            size: 110,
            color: Color.fromARGB(255, 73, 163, 76),
          ),
        ),
      ),
    );
  }
 
  Widget _buildProgressBar() {
    const double barHeight = 26;
    const double runnerSize = 40;
 
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final double barWidth = constraints.maxWidth;
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(end: _progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, animatedProgress, _) {
                return SizedBox(
                  height: runnerSize + barHeight,
                  child: Stack(
                    children: [
                      // Track
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 224, 224, 205),
                            borderRadius: BorderRadius.circular(barHeight),
                            border: Border.all(
                              color: const Color.fromARGB(255, 132, 180, 131),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      // Fill
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Container(
                          height: barHeight,
                          width: max(barHeight, barWidth * animatedProgress),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 163, 255, 126),
                                Color.fromARGB(255, 73, 163, 76),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(barHeight),
                          ),
                        ),
                      ),
                      // Little runner that travels along the bar
                      Positioned(
                        left: (barWidth - runnerSize) * animatedProgress,
                        bottom: barHeight - 6,
                        child: AnimatedBuilder(
                          animation: _bounceController,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(0, -6 * _bounceController.value),
                            child: child,
                          ),
                          child: const Icon(
                            Icons.eco,
                            size: runnerSize,
                            color: Color.fromARGB(255, 73, 163, 76),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(end: _progress),
          duration: const Duration(milliseconds: 400),
          builder: (context, animatedProgress, _) => Text(
            '${(animatedProgress * 100).round()}%',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 87, 42, 0),
            ),
          ),
        ),
      ],
    );
  }
 
  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 238, 215),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 132, 180, 131),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lightbulb,
            color: Color.fromARGB(255, 87, 42, 0),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              _tip,
              style: const TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 87, 42, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 72, color: Colors.redAccent),
        const SizedBox(height: 16),
        const Text(
          'Failed to load the story',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 87, 42, 0),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 73, 129, 82),
          ),
          onPressed: () {
            setState(() {
              _failed = false;
              _progress = 0.0;
            });
            _startLoading();
          },
          child: const Text('Retry', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}