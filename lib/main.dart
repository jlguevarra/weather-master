import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

void main() => runApp(CupertinoApp(
  debugShowCheckedModeBanner: false,
  home: Homepage(),
));

class Homepage extends StatefulWidget {
  const Homepage({super.key});

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
  Color iconColor = CupertinoColors.systemOrange; // Default color

  Map<String, dynamic> weatherData = {};

  Future<void> getWeatherData(String city) async {
    try {
      String link =
          "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=a7d420a62aba5ad305ef3885c399d830";
      final response = await http.get(Uri.parse(link));

      weatherData = jsonDecode(response.body);
      if (weatherData["cod"] == 200) {
        setState(() {
          location = city;
          temp = (weatherData["main"]["temp"] - 273.15).toStringAsFixed(0) + "°";
          weather = weatherData["weather"][0]['description'];
          humidity = (weatherData["main"]["humidity"]).toString() + "%";
          windSpeed = weatherData["wind"]['speed'].toString() + " kph";

          if (weather.contains("clear")) {
            weatherStatus = CupertinoIcons.sun_max;
          } else if (weather.contains("cloud")) {
            weatherStatus = CupertinoIcons.cloud;
          } else if (weather.contains("haze")) {
            weatherStatus = CupertinoIcons.sun_haze;
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

  void showErrorDialog(String message) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Message'),
            content: Text(message),
            actions: [
              CupertinoButton(
                  child: Text('Close',
                      style: TextStyle(color: CupertinoColors.destructiveRed)),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          );
        });
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
                      )),
                );

                if (result != null && result is Color) {
                  setState(() {
                    iconColor = result;
                  });
                }
              },
            )),
        child: SafeArea(
            child: temp != ""
                ? Center(
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Text('Location', style: TextStyle(fontSize: 35)),
                    SizedBox(height: 5),
                    Text('$location', style: TextStyle(fontSize: 25)),
                    SizedBox(height: 20),
                    Text(" $temp", style: TextStyle(fontSize: 80)),
                    Icon(weatherStatus,
                        color: iconColor, size: 100), // Use selected color
                    SizedBox(height: 10),
                    Text('$weather'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('H: $humidity'),
                        SizedBox(width: 10),
                        Text('W: $windSpeed')
                      ],
                    )
                  ],
                ))
                : Center(child: CupertinoActivityIndicator())));
  }
}

class SettingsPage extends StatefulWidget {
  final String location;
  final Function(String) onLocationChanged;
  final Color initialColor;

  const SettingsPage({
    required this.location,
    required this.onLocationChanged,
    required this.initialColor,
    Key? key,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String selectedLocation;
  bool metricSystem = true;
  bool lightMode = true;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.location;
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Location Row
            _buildListRow(
              CupertinoIcons.location,
              'Location',
              iconColor: CupertinoColors.white,
              iconBgColor: CupertinoColors.systemBlue,
              trailing: Row(
                children: [
                  Text(
                    selectedLocation,
                    style: const TextStyle(color: CupertinoColors.systemGrey),
                  ),
                  const SizedBox(width: 4),
                  const Icon(CupertinoIcons.chevron_right, size: 18),
                ],
              ),
              onTap: () async {
                final newLocation = await showCupertinoModalPopup<String>(
                  context: context,
                  builder: (context) => LocationPicker(
                    currentLocation: selectedLocation,
                  ),
                );
                if (newLocation != null) {
                  setState(() {
                    selectedLocation = newLocation;
                  });
                  widget.onLocationChanged(newLocation);
                  Navigator.pop(context);
                }
              },
            ),
            const _SettingsDivider(),

            // Icon Color Row
            _buildListRow(
              CupertinoIcons.paintbrush,
              'Icon Color',
              iconColor: CupertinoColors.white,
              iconBgColor: CupertinoColors.systemPurple,
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
                  const SizedBox(width: 4),
                  const Icon(CupertinoIcons.chevron_right, size: 18),
                ],
              ),
              onTap: () async {
                final newColor = await showCupertinoModalPopup<Color>(
                  context: context,
                  builder: (context) => ColorPicker(
                    currentColor: selectedColor,
                  ),
                );
                if (newColor != null) {
                  setState(() {
                    selectedColor = newColor;
                  });
                  Navigator.pop(context, newColor);
                }
              },
            ),
            const _SettingsDivider(),

            // Metric System Row
            _buildListRow(
              CupertinoIcons.textformat_123,
              'Metric System',
              iconColor: CupertinoColors.white,
              iconBgColor: CupertinoColors.systemGreen,
              trailing: CupertinoSwitch(
                value: metricSystem,
                onChanged: (value) {
                  setState(() {
                    metricSystem = value;
                  });
                },
              ),
            ),
            const _SettingsDivider(),

            // Light Mode Row
            _buildListRow(
              CupertinoIcons.sun_max,
              'Light Mode',
              iconColor: CupertinoColors.white,
              iconBgColor: CupertinoColors.systemYellow,
              trailing: CupertinoSwitch(
                value: lightMode,
                onChanged: (value) {
                  setState(() {
                    lightMode = value;
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
              iconBgColor: CupertinoColors.systemGrey,
              trailing: const Text(
                'Version: 1.0',
                style: TextStyle(color: CupertinoColors.systemGrey),
              ),
            ),
            const _SettingsDivider(),
          ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBgColor ?? CupertinoColors.systemGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? CupertinoColors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            trailing ?? const SizedBox(),
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.only(left: 60.0),
      color: CupertinoColors.separator,
    );
  }
}

class LocationPicker extends StatefulWidget {
  final String currentLocation;

  const LocationPicker({Key? key, required this.currentLocation}) : super(key: key);

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
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
      title: const Text("Location"),
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: CupertinoTextField(
          controller: _controller,
          placeholder: "Enter location",
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: CupertinoColors.black,
            borderRadius: BorderRadius.circular(8.0),
          ),
          style: const TextStyle(color: CupertinoColors.white),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text("Save", style: TextStyle(color: CupertinoColors.activeBlue)),
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
        ),
        CupertinoDialogAction(
          child: const Text("Close", style: TextStyle(color: CupertinoColors.destructiveRed)),
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

  const ColorPicker({Key? key, required this.currentColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text("Icon Color"),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: colorOptions.map((color) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context, color);
              },
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
          child: const Text("Close", style: TextStyle(color: CupertinoColors.destructiveRed)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}