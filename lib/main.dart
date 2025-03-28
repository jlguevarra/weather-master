import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart'as http;

void main()=>runApp(CupertinoApp(
  debugShowCheckedModeBanner: false,
  home: Homepage(),));

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override

  String location = "Russia";
  String temp = "";
  IconData? weatherStatus;
  String weather = "";
  String humidity ="";
  String windSpeed ="";

  Map<String, dynamic> weatherData = {};

  Future<void> getWeatherData() async{

    try {
      String link = "https://api.openweathermap.org/data/2.5/weather?q="+location+"&appid=a7d420a62aba5ad305ef3885c399d830";
      final response = await http.get(
          Uri.parse(link)
      );

      weatherData =jsonDecode(response.body);
      try {
        setState(() {
          temp = (weatherData["main"]["temp"] -273.15).toStringAsFixed(0) + "°";
          weather = weatherData["weather"][0]['description'];
          humidity = (weatherData["main"]["humidity"]).toString() + "%";
          windSpeed = weatherData["wind"]['speed'].toString() + " kph";

          if (weather!.contains("clear")){
            weatherStatus = CupertinoIcons.sun_max;
          }else if (weather!.contains("cloud")){
            weatherStatus = CupertinoIcons.cloud;
          }else if (weather!.contains("haze")){
            weatherStatus = CupertinoIcons.sun_haze;
          }


        });
      }catch (e){
        showCupertinoDialog(context: context, builder: (context){
          return CupertinoAlertDialog(
            title: Text('Message'),
            content: Text('City not Found'),
            actions: [
              CupertinoButton(child: Text('Close', style: TextStyle(color: CupertinoColors.destructiveRed)), onPressed: (){
                Navigator.pop(context);
              })
            ],
          );
        });

      }
      print(weatherData["cod"]);
      if (weatherData["cod"]==200){



      }else
        print("Invalid City");

    }catch (e){

      showCupertinoDialog(context: context, builder: (context){
        return CupertinoAlertDialog(
          title: Text('Message'),
          content: Text('No Internet Connection'),
          actions: [
            CupertinoButton(child: Text('Close', style: TextStyle(color: CupertinoColors.destructiveRed)), onPressed: (){
              Navigator.pop(context);
            }),
            CupertinoButton(child: Text('Retry', style: TextStyle(color: CupertinoColors.systemGreen)), onPressed: (){
              Navigator.pop(context);
              getWeatherData();
            }),
          ],
        );
      });
    }
  }
  @override
  void initState() {
    getWeatherData();
    super.initState();
  }

  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            middle: Text ("iWeather"),
            trailing: CupertinoButton(child: Icon(CupertinoIcons.settings), onPressed: (){})
        ),
        child: SafeArea(child: temp != "" ? Center(
          child: Column(
            children: [
              SizedBox(height: 50,),
              Text('My Location', style: TextStyle(fontSize: 35),),
              SizedBox(height: 5,),
              Text('$location'),
              SizedBox(height: 20,),
              Text(" $temp", style: TextStyle(fontSize: 80)),
              Icon(weatherStatus, color: CupertinoColors.systemOrange,size: 100,),
              SizedBox(height: 10,),
              Text('$weather'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('H: $humidity'),
                  SizedBox(width: 10,),
                  Text('W: $windSpeed')
                ],
              )
              //
            ],
          ),
        ): Center(child: CupertinoActivityIndicator(),) ));
  }
}
