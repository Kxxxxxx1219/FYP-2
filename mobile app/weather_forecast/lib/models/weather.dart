import 'package:intl/intl.dart';

class Weather {
  final DateTime timestamp;
  final double temp_celsius;
  final double temp_fahrenheit;
  final double minTempCelsius;
  final double maxTempCelsius;
  final double wind_speed_mph;
  final double pressure;
  final double humidity;

  Weather({
    required this.timestamp,
    required this.temp_celsius,
    required this.temp_fahrenheit,
    required this.minTempCelsius,
    required this.maxTempCelsius,
    required this.wind_speed_mph,
    required this.pressure,
    required this.humidity,
  });

  // Factory method to create Weather from CSV row
  factory Weather.fromCsv(List<dynamic> row) {
    final dateFormat = DateFormat('M/dd/yyyy H:mm');
    return Weather(
      timestamp: dateFormat.parse(row[0] as String), // Parse timestamp
      temp_celsius: row[1].toDouble(),
      temp_fahrenheit: row[2].toDouble(),
      wind_speed_mph: row[3].toDouble(),
      pressure: row[4].toDouble(),
      humidity: row[5].toDouble(),
      minTempCelsius:
          row[1].toDouble(), // Map accordingly if your CSV has these fields
      maxTempCelsius: row[2].toDouble(), // Adjust if necessary based on CSV
    );
  }
}
