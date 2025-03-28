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
                final newLocation = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => SettingsPage(location: location)),
                );

                if (newLocation != null && newLocation is String && newLocation != location) {
                  getWeatherData(newLocation);
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
                        color: CupertinoColors.systemOrange, size: 100),
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

  const SettingsPage({required this.location, Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String selectedLocation;
  bool metricSystem = true;
  bool lightMode = true;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.location;
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
                }
              },
            ),
            const _SettingsDivider(),

            // Icon Row
            _buildListRow(
              CupertinoIcons.square_grid_2x2,
              'Icon',
              iconColor: CupertinoColors.white,
              iconBgColor: CupertinoColors.systemPurple,
              trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
              onTap: () {
                // Handle icon setting
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

            // Save Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  child: const Text('Save'),
                  onPressed: () {
                    Navigator.pop(context, selectedLocation);
                  },
                ),
              ),
            ),
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

  const LocationPicker({required this.currentLocation, Key? key}) : super(key: key);

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late final TextEditingController _controller;

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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        middle: const Text('Change Location'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Save'),
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              Navigator.pop(context, _controller.text.trim());
            }
            //
          },
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CupertinoTextField(
            controller: _controller,
            placeholder: 'Enter city name',
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            autofocus: true,
          ),
        ),
      ),
    );
  }
}