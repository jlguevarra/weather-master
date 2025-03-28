import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _lightMode = true;

  void toggleTheme(bool value) {
    setState(() {
      _lightMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: _lightMode ? Brightness.light : Brightness.dark,
      ),
      home: Homepage(
        lightMode: _lightMode,
        onThemeChanged: toggleTheme,
      ),
    );
  }
}

class Homepage extends StatefulWidget {
  final bool lightMode;
  final Function(bool) onThemeChanged;

  const Homepage({
    required this.lightMode,
    required this.onThemeChanged,
    super.key,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}



class _HomepageState extends State<Homepage> {
  String location = "Baguio";
  String temp = "";
  IconData? weatherStatus;
  String weather = "";
  String humidity = "";
  String windSpeed = "";
  Color iconColor = CupertinoColors.systemOrange;
  bool useFahrenheit = false; // Default to Celsius (false)
  double? kelvinTemp;

  Map<String, dynamic> weatherData = {};

  Future<void> getWeatherData(String city) async {
    try {
      String link = "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=a7d420a62aba5ad305ef3885c399d830";
      final response = await http.get(Uri.parse(link));

      weatherData = jsonDecode(response.body);
      if (weatherData["cod"] == 200) {
        setState(() {
          location = city;
          kelvinTemp = weatherData["main"]["temp"];
          updateTemperatureDisplay();
          weather = weatherData["weather"][0]['description'];
          humidity = "${weatherData["main"]["humidity"]}%";
          windSpeed = "${weatherData["wind"]['speed']} kph";

          if (weather.contains("clear")) {
            weatherStatus = CupertinoIcons.sun_max;
          } else if (weather.contains("cloud")) {
            weatherStatus = CupertinoIcons.cloud;
          } else if (weather.contains("haze")) {
            weatherStatus = CupertinoIcons.sun_haze;
          }else if (weather.contains("snow")) {
            weatherStatus = CupertinoIcons.snow;
          }else if (weather.contains("rain")) {
            weatherStatus = CupertinoIcons.cloud_rain;
          }else if (weather.contains("thunderstorm")) {
            weatherStatus = CupertinoIcons.cloud_bolt_rain;
          } else {
            weatherStatus = CupertinoIcons.cloud_sun;
          }
        });
      } else {
        showErrorDialog("City not Found");
      }
    } catch (e) {
      showErrorDialog("No Internet Connection");
    }
  }

  void updateTemperatureDisplay() {
    if (kelvinTemp != null) {
      setState(() {
        temp = useFahrenheit
            ? "${((kelvinTemp! - 273.15) * 9/5 + 32).toStringAsFixed(0)}°" // Fahrenheit
            : "${(kelvinTemp! - 273.15).toStringAsFixed(0)}°"; // Celsius
      });
    }
  }

  void toggleTemperatureUnit(bool value) {
    setState(() {
      useFahrenheit = value;
      updateTemperatureDisplay();
    });
  }

  void showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Message'),
          content: Text(message),
          actions: [
            CupertinoButton(
              child: Text('Close', style: TextStyle(color: CupertinoColors.destructiveRed)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getWeatherData(location);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("iWeather"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.settings),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => SettingsPage(
                  location: location,
                  onLocationChanged: getWeatherData,
                  initialColor: iconColor,
                  useFahrenheit: useFahrenheit,
                  onUnitChanged: toggleTemperatureUnit,
                  lightMode: widget.lightMode,
                  onThemeChanged: widget.onThemeChanged,
                ),
              ),
            );
            if (result != null && result is Color) {
              setState(() => iconColor = result);
            }
          },
        ),
      ),
      child: SafeArea(
        child: temp != ""
            ? SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text('Location', style: TextStyle(fontSize: 35)),
                  SizedBox(height: 5),
                  Text(location, style: TextStyle(fontSize: 25)),
                  SizedBox(height: 20),
                  Text(" $temp", style: TextStyle(fontSize: 80)),
                  Icon(weatherStatus, color: iconColor, size: 100),
                  SizedBox(height: 10),
                  Text(weather),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('H: $humidity'),
                      SizedBox(width: 10),
                      Text('W: $windSpeed')
                    ],
                  ),
                  SizedBox(height: 40), // Extra space for scrolling
                ],
              ),
            ),
          ),
        )
            : Center(child: CupertinoActivityIndicator()),
      ),
    );
  }
}
class TeamMember {
  final String name;
  final String imagePath;

  TeamMember(this.name, this.imagePath);
}

final List<TeamMember> teamMembers = [
  TeamMember('Christian Caparra', 'assets/images/ChristianCaparra.jpg'),
  TeamMember('John Lloyd Guevarra', 'assets/images/JL1.jpg'),
  TeamMember('Samuel Miranda', 'assets/images/sam.jpg'),
  TeamMember('Jhuniel Galang', 'assets/images/Jhuniel.jpg'),
  TeamMember('Michael Deramos', 'assets/images/mike.jpg'),
];

class SettingsPage extends StatefulWidget {
  final String location;
  final Function(String) onLocationChanged;
  final Color initialColor;
  final bool useFahrenheit;
  final Function(bool) onUnitChanged;
  // Add these:
  final bool lightMode;
  final Function(bool) onThemeChanged;

  const SettingsPage({
    required this.location,
    required this.onLocationChanged,
    required this.initialColor,
    required this.useFahrenheit,
    required this.onUnitChanged,
    // Add these:
    required this.lightMode,
    required this.onThemeChanged,
    super.key,
  });

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late String selectedLocation;
  late bool useFahrenheit;
  late Color selectedColor;
  // REMOVE: bool lightMode (we'll use widget.lightMode instead)

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.location;
    selectedColor = widget.initialColor;
    useFahrenheit = widget.useFahrenheit;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Location Row
            _buildListRow(
              CupertinoIcons.location,
              'Location',
              iconColor: CupertinoColors.white,
              iconBgColor: CupertinoColors.systemOrange,
              trailing: Row(
                children: [
                  Text(selectedLocation, style: TextStyle(color: CupertinoColors.systemGrey)),
                  SizedBox(width: 4),
                  Icon(CupertinoIcons.chevron_right, size: 18),
                ],
              ),
              onTap: () async {
                final newLocation = await showCupertinoModalPopup<String>(
                  context: context,
                  builder: (context) => LocationPicker(currentLocation: selectedLocation),
                );
                if (newLocation != null) {
                  setState(() => selectedLocation = newLocation);
                  widget.onLocationChanged(newLocation);
                  Navigator.pop(context);
                }
              },
            ),
            const _SettingsDivider(),

            // Icon Color Row
            _buildListRow(
              CupertinoIcons.color_filter,
              'Icon',
              iconColor: CupertinoColors.white,
              iconBgColor: CupertinoColors.systemPink,
              trailing: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: CupertinoColors.systemGrey),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(CupertinoIcons.chevron_right, size: 18),
                ],
              ),
              onTap: () async {
                final newColor = await showCupertinoModalPopup<Color>(
                  context: context,
                  builder: (context) => ColorPicker(currentColor: selectedColor),
                );
                if (newColor != null) {
                  setState(() => selectedColor = newColor);
                  Navigator.pop(context, newColor);
                }
              },
            ),
            const _SettingsDivider(),

            // Metric System Row
            _buildListRow(
              CupertinoIcons.gauge,
              'Metric System',
              iconColor: CupertinoColors.white,
              iconBgColor: CupertinoColors.systemGreen,
              trailing: CupertinoSwitch(
                value: useFahrenheit,
                onChanged: (value) {
                  setState(() => useFahrenheit = value);
                  widget.onUnitChanged(value);
                },
              ),
            ),
            const _SettingsDivider(),

            // Light Mode Row
            _buildListRow(
              CupertinoIcons.light_max,
              'Light Mode',
              iconColor: CupertinoColors.white,
              iconBgColor: CupertinoColors.systemYellow,
              trailing: CupertinoSwitch(
                value: widget.lightMode, // Ensure this is properly updated
                onChanged: (value) {
                  setState(() {
                    widget.onThemeChanged(value); // Update theme
                  });
                },
              ),
            ),

            const _SettingsDivider(),

            // About Row
            _buildListRow(
              CupertinoIcons.info,
              'About',
              iconColor: CupertinoColors.white,
              iconBgColor: CupertinoColors.systemBlue,
              trailing: const Text('Version: 1.0',
                  style: TextStyle(color: CupertinoColors.systemGrey)),
              onTap: () => _showTeamMembersDialog(context),
            ),
            const _SettingsDivider(),
          ],
        ),
      ),
      ),
    );
  }
  void _showTeamMembersDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Team Members',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Scrollable team members list
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: teamMembers.map((member) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: AssetImage(member.imagePath),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Text(
                                  member.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                child: const Text('Close'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildListRow(
      IconData icon,
      String title, {
        Color? iconColor,
        Color? iconBgColor,
        Widget? trailing,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBgColor ?? CupertinoColors.systemGrey,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Icon(icon, size: 20, color: iconColor ?? CupertinoColors.white),
              ),
            ),
            SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400))),
            trailing ?? SizedBox(),
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: EdgeInsets.only(left: 15.0, right: 15.0),

      color: CupertinoColors.systemBrown,
    );
  }
}

class LocationPicker extends StatefulWidget {
  final String currentLocation;

  const LocationPicker({super.key, required this.currentLocation});

  @override
  LocationPickerState createState() => LocationPickerState();
}

class LocationPickerState extends State<LocationPicker> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentLocation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text("Location"),
      content: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: CupertinoTextField(
          controller: _controller,
          placeholder: "Enter location",
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: CupertinoColors.black,
            borderRadius: BorderRadius.circular(8.0),
          ),
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          child: Text("Save", style: TextStyle(color: CupertinoColors.activeBlue)),
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
        ),
        CupertinoDialogAction(
          child: Text("Close", style: TextStyle(color: CupertinoColors.destructiveRed)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class ColorPicker extends StatelessWidget {
  final Color currentColor;

  final List<Color> colorOptions = const [
    CupertinoColors.systemRed,
    CupertinoColors.systemOrange,
    CupertinoColors.systemYellow,
    CupertinoColors.systemGreen,
    CupertinoColors.systemBlue,
    CupertinoColors.systemPurple,
    CupertinoColors.systemPink,
    CupertinoColors.systemGrey,
  ];

  const ColorPicker({super.key, required this.currentColor});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text("Icon Color"),
      content: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: colorOptions.map((color) {
            return GestureDetector(
              onTap: () => Navigator.pop(context, color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color == currentColor
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                    width: 2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          child: Text("Close", style: TextStyle(color: CupertinoColors.destructiveRed)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}


