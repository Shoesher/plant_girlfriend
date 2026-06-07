import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_girlfriend/pages/game.dart';

class Settings extends StatefulWidget { // Changed to StatefulWidget
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<Settings> {
  // State variables for various settings
  bool _darkModeEnabled = true;
  final List<String> _fieldOptions = ['Fullscreen', 'Windowed']; // Default language
  final List<String> _motorOptions = ['NEO', 'CIM', 'KrakenX60'];
  String _selectedField = 'Fullscreen';
  String _selectedMotor = 'NEO';
  double _robotMass = 74.1;
  double _robotLength = 0.6;
  double _robotWidth = 0.5;
  double _robotRatio = 8;
  double _bumperWidth = 0.15;
  double _wheelRadius = 0.048;
  final String _appVersion = '1.0.0'; 
  double textSpeed = Game_().speed.toDouble();
  double musicVolume = 50;
  double soundVolume = 50;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Load saved settings when the page initializes
  }

  // Function to load all settings from SharedPreferences
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkModeEnabled = prefs.getBool('darkMode') ?? false;
      _selectedField = prefs.getString('fieldType') ?? 'Fullscreen';
      _selectedMotor = prefs.getString('motorType') ?? 'NEO'; 
    });
  }

  // Generic function to save a single setting
  Future<void> _saveSetting(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } 
    else if (value is String) {
      await prefs.setString(key, value);
    }
    else if(value is double){
      await prefs.setDouble(key, value);
    }
    // You can add more types (int, double) if needed for other settings
  }

  // Function to clear all app data
  Future<void> _clearAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // This clears ALL stored SharedPreferences data

    // Reset local state variables to their default values after clearing
    setState(() {
      _darkModeEnabled = false;
      _selectedField = _fieldOptions[0];
      _selectedMotor = _motorOptions[0];
      _robotMass = 74.1;
      _robotLength = 0.6;
      _robotWidth = 0.5;
      _robotRatio = 8;
      _bumperWidth = 0.15;
      _wheelRadius = 0.048;
      // Reset any other settings variables you might add to their defaults
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data reset'),
        backgroundColor: Colors.green,
      ),
    );
    // You might want to navigate the user back to the homepage or prompt a restart
    // for the changes to fully take effect across the app.
  }

  // Dialog to confirm clearing data
  void _showClearDataConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Data Reset'),
          content: const Text(
              'Are you sure you want to clear all of your data? All of your config settings will be restored to their defaults.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                _clearAllData(); // Perform the clear action
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Clear Data', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String getUnit(int tab){
    String a;
    if(tab == 0){
      a = 'KG';
      return a;
    }
    else{
      a = 'M';
      return a;
    }
  } 

  // Dialog for changing username
  void _showSettingsDialog(int action) {
    TextEditingController massController = TextEditingController(text: _robotMass.toString());
    TextEditingController rLengthcontroller = TextEditingController(text: _robotLength.toString());
    TextEditingController rWidthcontroller = TextEditingController(text: _robotWidth.toString());
    TextEditingController bWidthcontroller = TextEditingController(text: _bumperWidth.toString());
    TextEditingController ratioController = TextEditingController(text: _robotRatio.toString());
    TextEditingController radiusController = TextEditingController(text: _wheelRadius.toString());

    List<TextEditingController> settingsController = [massController, rLengthcontroller, rWidthcontroller, bWidthcontroller, ratioController, radiusController];
    List<String> sharedPrefs = ['botMass', 'botLength', 'botWidth', 'botBumper', 'botRatio', 'botWheels'];
    String unit = getUnit(action);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Value ($unit)', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(144, 0, 0, 0),
          content: TextField(
            controller: settingsController[action],
            style: TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'testing',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (settingsController[action].text.isNotEmpty) {
                  double? parsedValue = double.tryParse(settingsController[action].text);
                  if (parsedValue != null) {
                    await _saveSetting(sharedPrefs[action], parsedValue);
                    setState(() {
                      switch (action) {
                        case 0: _robotMass = parsedValue; break;
                        case 1: _robotLength = parsedValue; break;
                        case 2: _robotWidth = parsedValue; break;
                        case 3: _bumperWidth = parsedValue; break;
                        case 4: _robotRatio = parsedValue; break;
                        case 5: _wheelRadius = parsedValue; break;
                      }
                    });
                  }
                  setState(() {
                    // _selectedMotor = settingsController[action].text; // Update UI immediately
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data updated successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cannot be empty!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 246, 234),
      appBar: AppBar(
        title: const Text('Settings',
           style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 163, 255, 126),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700), 
          child: ListView(
            padding: const EdgeInsets.all(25.0), 
            children: [
              _buildSectionHeader('Display'),
              Card(
                color: const Color.fromARGB(255, 255, 238, 215),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [ // Visual separator
                      ListTile(
                        leading: const Icon(Icons.monitor, color: Color.fromARGB(255, 87, 42, 0)),
                        title: const Text('Screen Preference', style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 87, 42, 0))),
                        subtitle: Text('Current: $_selectedField', style: TextStyle(color: const Color.fromARGB(255, 78, 78, 78))),
                        trailing: DropdownButton<String>(
                          value: _selectedField,
                          dropdownColor: Colors.black12,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedField = newValue;
                              });
                              _saveSetting('fieldType', newValue);
                              // For full localization, you'd update locale here
                            }
                          },
                          items: _fieldOptions.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 87, 42, 0))),
                            );
                          }).toList(),
                        ),
                      ),
                      const Divider(indent: 16, endIndent: 16),
                    ],
                  ),
                ),
              ),

              _buildSectionHeader('Gameplay'),
              Card(
                color: const Color.fromARGB(255, 255, 238, 215),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Text('Text Read Speed',
                      style: TextStyle(color: Color.fromARGB(255, 87, 42, 0), fontSize: 18),
                    ),
                    Slider(
                      value: textSpeed,
                      min: 0.0,
                      max: 100.0,
                      divisions: 10, // Creates discrete snapping points
                      label: textSpeed.round().toString(), // Shows value indicator bubble
                      activeColor: const Color.fromARGB(255, 58, 243, 33),
                      inactiveColor: const Color.fromARGB(255, 33, 243, 79).withOpacity(0.3),
                      onChanged: (double newValue) {
                        // 3. Update state to trigger a redraw
                        setState(() {
                          textSpeed = newValue;
                        });
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16),
                  ],
                ),
              ),

              _buildSectionHeader('Volume'),
              Card(
                color: const Color.fromARGB(255, 255, 238, 215),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Text('Music Volume',
                      style: TextStyle(color: Color.fromARGB(255, 87, 42, 0), fontSize: 18),
                    ),
                    Slider(
                      value: musicVolume,
                      min: 0.0,
                      max: 100.0,
                      divisions: 10, // Creates discrete snapping points
                      label: musicVolume.round().toString(), // Shows value indicator bubble
                      activeColor: const Color.fromARGB(255, 58, 243, 33),
                      inactiveColor: const Color.fromARGB(255, 33, 243, 79).withOpacity(0.3),
                      onChanged: (double newValue) {
                        // 3. Update state to trigger a redraw
                        setState(() {
                          musicVolume = newValue;
                        });
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    Text('Sound Volume',
                      style: TextStyle(color: Color.fromARGB(255, 87, 42, 0), fontSize: 18),
                    ),
                    Slider(
                      value: soundVolume,
                      min: 0.0,
                      max: 100.0,
                      divisions: 10, // Creates discrete snapping points
                      label: soundVolume.round().toString(), // Shows value indicator bubble
                      activeColor: const Color.fromARGB(255, 58, 243, 33),
                      inactiveColor: const Color.fromARGB(255, 33, 243, 79).withOpacity(0.3),
                      onChanged: (double newValue) {
                        // 3. Update state to trigger a redraw
                        setState(() {
                          soundVolume = newValue;
                        });
                      },
                    ),  
                    const Divider(indent: 16, endIndent: 16),
                  ],
                ),
              ),

              _buildSectionHeader('Game progress & Data'),
              Card(
                color: const Color.fromARGB(255, 255, 238, 215),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Reset', style: TextStyle(fontSize: 18, color: Colors.red)),
                  subtitle: const Text('Resets all app data and configuration settings.', style: TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _showClearDataConfirmation, // Call the confirmation dialog
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to create consistent section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 10.0, left: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}