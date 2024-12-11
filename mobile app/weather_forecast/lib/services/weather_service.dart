import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/weather.dart'; // Import your Weather model

class WeatherService {
  Future<List<Weather>> loadWeatherData() async {
    try {
      // Load the CSV file from the assets folder
      final rawData = await rootBundle.loadString(
          "assets/denormalized_predicted_next_6_months_with_timestamps_final.csv");

      // Parse the CSV data into a list of lists
      List<List<dynamic>> csvTable = CsvToListConverter().convert(rawData);

      // Check if CSV data is being parsed correctly
      if (csvTable.isEmpty) {
        throw Exception("No data found in CSV");
      }

      // Convert each row into a Weather object and return the list
      return csvTable.skip(1).map((row) => Weather.fromCsv(row)).toList();
    } catch (e) {
      // Log the error for debugging
      print("Error loading weather data: $e");
      rethrow; // Re-throw the error to be caught by FutureBuilder in the UI
    }
  }
}
