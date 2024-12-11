import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherGraphScreen extends StatefulWidget {
  final DateTime selectedDate;

  WeatherGraphScreen({required this.selectedDate});

  @override
  _WeatherGraphScreenState createState() => _WeatherGraphScreenState();
}

class _WeatherGraphScreenState extends State<WeatherGraphScreen> {
  List<Weather> _selectedDateWeather = [];
  bool _isLoading = true;
  bool _showFourHourInterval = true; // State variable for toggling

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      List<Weather> allWeatherData = await WeatherService().loadWeatherData();

      // Filter based on selected date
      _selectedDateWeather = allWeatherData.where((weather) {
        return DateFormat('yyyy-MM-dd').format(weather.timestamp) ==
            DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      }).toList();

      // If showing every four hours, filter the list
      if (_showFourHourInterval) {
        _selectedDateWeather = _selectedDateWeather
            .asMap()
            .entries
            .where((entry) => entry.key % 4 == 0) // Get every fourth entry
            .map((entry) => entry.value)
            .toList();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error in _loadData: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleInterval() {
    setState(() {
      _showFourHourInterval = !_showFourHourInterval; // Toggle the state
      _loadData(); // Reload data based on the new state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Temperature Graph',
          style: GoogleFonts.josefinSans(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            top: 20.0), // Add padding to move everything down a bit
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: _toggleInterval,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[800],
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 32.0),
                      ),
                      child: Text(
                        _showFourHourInterval
                            ? 'Show 24-Hour Data'
                            : 'Show 4-Hour Data',
                        style: GoogleFonts.josefinSans(
                            fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _selectedDateWeather.isEmpty
                      ? Center(
                          child: Text('No data available for selected date'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: SizedBox(
                              // Dynamically adjust the width based on the toggle state
                              width: _showFourHourInterval
                                  ? MediaQuery.of(context).size.width *
                                      0.9 // 90% of the screen width when showing 4-hour data
                                  : _selectedDateWeather.length *
                                      80.0, // Normal width when showing 24-hour data
                              child: Padding(
                                padding: const EdgeInsets.only(top: 50.0),
                                child: LineChart(LineChartData(
                                  minX: 0,
                                  maxX: _selectedDateWeather.length.toDouble() -
                                      1,
                                  minY: _getMinY(),
                                  maxY: _getMaxY(),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _getTemperatureSpots(),
                                      isCurved: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.yellow.shade700,
                                          Colors.orange
                                        ],
                                      ),
                                      barWidth: 4,
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.yellow.withOpacity(0.3),
                                            Colors.orange.withOpacity(0.1)
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 2,
                                        reservedSize:
                                            80, // Increased for padding
                                        getTitlesWidget: (value, meta) {
                                          if (value >= _getMinY() &&
                                              value <= _getMaxY()) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 12.0),
                                              child: Text(
                                                  '${value.toStringAsFixed(1)}°C',
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                            );
                                          }
                                          return Container();
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index >= 0 &&
                                              index <
                                                  _selectedDateWeather.length) {
                                            final timestamp =
                                                _selectedDateWeather[index]
                                                    .timestamp;
                                            final formattedTime =
                                                DateFormat('HH:mm')
                                                    .format(timestamp);
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(formattedTime,
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                            );
                                          }
                                          return Container();
                                        },
                                      ),
                                    ),
                                    topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                        color: Colors.white10, strokeWidth: 1),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(color: Colors.white24),
                                  ),
                                )),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Convert temperature data to spots for the chart
  List<FlSpot> _getTemperatureSpots() {
    return _selectedDateWeather
        .asMap()
        .map((index, weather) => MapEntry(
            index,
            FlSpot(index.toDouble(),
                double.parse(weather.temp_celsius.toStringAsFixed(1)))))
        .values
        .toList();
  }

  // Get minimum Y value for better scaling
  double _getMinY() {
    if (_selectedDateWeather.isEmpty) return 0; // Or return a default value
    return _selectedDateWeather
        .map((weather) => weather.temp_celsius)
        .reduce((a, b) => a < b ? a : b)
        .floorToDouble(); // Return the integer part of the minimum temperature
  }

  // Get maximum Y value for better scaling
  double _getMaxY() {
    if (_selectedDateWeather.isEmpty) return 40; // Default maximum temperature
    return _selectedDateWeather
        .map((weather) => weather.temp_celsius)
        .reduce((a, b) => a > b ? a : b)
        .ceilToDouble(); // Return the integer part of the maximum temperature
  }
}
