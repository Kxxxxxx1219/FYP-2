import 'package:flutter/material.dart';
import 'screens/weather_screen.dart'; // Import the WeatherScreen
import 'screens/home.dart'; // Import the HomePage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(), // Set the HomePage as the initial screen
      debugShowCheckedModeBanner: false, // Removes the "Debug" banner
    );
  }
}
