import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/weathergraph_screen.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late DateTime _selectedDate;
  List<Weather> _allWeatherData = [];
  List<Weather> _filteredWeatherData = [];
  Weather? _currentHourWeather;
  Weather? selectedWeather;

  final ScrollController _scrollController = ScrollController();

  void _scrollToCurrentHour() {
    final now = DateTime.now();
    // now = now.add(Duration(hours: -12));
    // debugPrint(now.toString());
    int currentHourIndex = _filteredWeatherData.indexWhere((weather) =>
        weather.timestamp.hour == now.hour &&
        DateFormat('yyyy-MM-dd').format(weather.timestamp) ==
            DateFormat('yyyy-MM-dd').format(_selectedDate));
    debugPrint((currentHourIndex).toString());
    bool debug = false;
    if (debug) {
      currentHourIndex = 2; // 1am
    }
    currentHourIndex -= 1;
    if (currentHourIndex != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          (currentHourIndex * 126.0) + 7, // Assuming each item is 120px wide
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _showIconInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Icon Information",
            style: GoogleFonts.josefinSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sunny Row
              Row(
                children: [
                  Image.asset(
                    'assets/icons/sun.png',
                    width: 24,
                    height: 24,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text.rich(
                        TextSpan(
                          text: "Sunny\n",
                          style: GoogleFonts.josefinSans(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text:
                                  "Temperature: > 20°C\nHumidity: < 50%\nWind Speed: <= 10 km/h",
                              style: GoogleFonts.josefinSans(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Light Rain in Day Row
              Row(
                children: [
                  Image.asset(
                    'assets/icons/light-rain-day.png',
                    width: 24,
                    height: 24,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text.rich(
                        TextSpan(
                          text: "Light Rain in Day\n",
                          style: GoogleFonts.josefinSans(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text:
                                  "Temperature: < 20°C\nHumidity: >= 80%\nWind Speed: <= 10 km/h",
                              style: GoogleFonts.josefinSans(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Cloudy Row
              Row(
                children: [
                  Image.asset(
                    'assets/icons/cloudy.png',
                    width: 24,
                    height: 24,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text.rich(
                        TextSpan(
                          text: "Cloudy\n",
                          style: GoogleFonts.josefinSans(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text:
                                  "Humidity: 50% <= Humidity <= 80%\nWind Speed: <= 10 km/h",
                              style: GoogleFonts.josefinSans(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Light Rain at Night Row
              Row(
                children: [
                  Image.asset(
                    'assets/icons/light-rain-night.png',
                    width: 24,
                    height: 24,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text.rich(
                        TextSpan(
                          text: "Light Rain at Night\n",
                          style: GoogleFonts.josefinSans(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: "Humidity: >= 80%\nWind Speed: <= 10 km/h",
                              style: GoogleFonts.josefinSans(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                "Close",
                style: GoogleFonts.josefinSans(fontSize: 18),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Method to get the current weather condition for 7 AM or the current time
  String _getCurrentWeatherCondition() {
    // Default to Cloudy if no data is loaded
    if (_filteredWeatherData.isEmpty) return 'Cloudy';

    // Get the weather data for the current hour
    final currentHourWeather = _filteredWeatherData.firstWhere(
      (weather) => weather.timestamp.hour == DateTime.now().hour,
      orElse: () => _filteredWeatherData.first,
    );

    // Get the current time to decide whether it's day or night
    bool isDayTime = _isDayTimeBasedOnTimestamp(currentHourWeather.timestamp);

    // Define conditions for Sunny, Cloudy, Rain, etc.
    if (currentHourWeather.temp_celsius > 20 &&
        currentHourWeather.humidity < 60) {
      return 'Sunny'; // Sunny when it's warm and dry
    } else if (currentHourWeather.humidity >= 80) {
      return isDayTime
          ? 'Light Rain at Day'
          : 'Light Rain at Night'; // Light Rain depending on the time of day
    } else if (currentHourWeather.temp_celsius <= 20 &&
        currentHourWeather.humidity < 80) {
      return 'Cloudy'; // Cloudy if temp is cool and humidity is moderate
    } else {
      return isDayTime
          ? 'Cloudy'
          : 'Light Rain at Night'; // Default to cloudy or rainy at night
    }
  }

  Color _getBackgroundColor(String condition) {
    switch (condition) {
      case 'Sunny':
        return Color(0xFFFFB74D); // Light orange for Sunny
      case 'Cloudy':
        return Color(0xFFB0BEC5); // Light grey for Cloudy
      case 'Light Rain at Day':
        return Color(0xFF78909C); // Slate blue for light rain during the day
      case 'Light Rain at Night':
        return Color(0xFF303F9F); // Dark indigo for light rain at night
      default:
        return Colors.white; // Default to white if no matching condition
    }
  }

// Renamed helper method to check if it is day or night based on the timestamp
  bool _isDayTimeBasedOnTimestamp(DateTime timestamp) {
    // For example, consider it daytime from 6 AM to 6 PM
    return timestamp.hour >= 6 && timestamp.hour < 18;
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    // Load all weather data initially
    WeatherService().loadWeatherData().then((data) {
      setState(() {
        _allWeatherData = data;
        _filterWeatherDataByDate();
        _scrollToCurrentHour(); // Scroll to current hour once data is loaded
      });
    });
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 9, 25),
      lastDate: DateTime(2025, 7, 1),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _filterWeatherDataByDate();
        _scrollToCurrentHour(); // Scroll to current hour when date changes
      });
    }
  }

  void _filterWeatherDataByDate() {
    _filteredWeatherData = _allWeatherData.where((weather) {
      return DateFormat('yyyy-MM-dd').format(weather.timestamp) ==
          DateFormat('yyyy-MM-dd').format(_selectedDate);
    }).toList();
  }

  // Method to get 7-day forecast data with separate icon selection
  List<Map<String, dynamic>> _getWeeklyForecast() {
    DateTime startDate = _selectedDate.add(Duration(days: 1));
    List<Map<String, dynamic>> weeklyData = [];

    for (int i = 0; i < 7; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      List<Weather> dailyWeather = _allWeatherData.where((weather) {
        return DateFormat('yyyy-MM-dd').format(weather.timestamp) ==
            DateFormat('yyyy-MM-dd').format(currentDate);
      }).toList();

      if (dailyWeather.isNotEmpty) {
        double avgTemp =
            dailyWeather.map((w) => w.temp_celsius).reduce((a, b) => a + b) /
                dailyWeather.length;

        // Calculate min and max temperatures
        double minTemp = dailyWeather
            .map((w) => w.temp_celsius)
            .reduce((a, b) => a < b ? a : b);
        double maxTemp = dailyWeather
            .map((w) => w.temp_celsius)
            .reduce((a, b) => a > b ? a : b);

        String iconPath = _getDailyWeatherIcon(avgTemp); // Use avgTemp for icon

        weeklyData.add({
          'date': currentDate,
          'avgTemp': avgTemp,
          'minTemp': minTemp,
          'maxTemp': maxTemp,
          'iconPath': iconPath,
        });
      }
    }

    return weeklyData;
  }

  // Methods to get average humidity, wind speed, and pressure
  double _getAverageHumidity() {
    if (_filteredWeatherData.isEmpty) return 0.0;
    return _filteredWeatherData.map((w) => w.humidity).reduce((a, b) => a + b) /
        _filteredWeatherData.length;
  }

  double _getAverageWindSpeed() {
    if (_filteredWeatherData.isEmpty) return 0.0;
    return _filteredWeatherData
            .map((w) => w.wind_speed_mph)
            .reduce((a, b) => a + b) /
        _filteredWeatherData.length;
  }

  double _getAveragePressure() {
    if (_filteredWeatherData.isEmpty) return 0.0;
    return _filteredWeatherData.map((w) => w.pressure).reduce((a, b) => a + b) /
        _filteredWeatherData.length;
  }

  // Widget to display average humidity, wind speed, and pressure
  Widget _buildWeatherMetrics() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildWeatherMetric(
              'Humidity', _getAverageHumidity(), 'assets/icons/humidity.png'),
          _buildWeatherMetric(
              'Wind Speed', _getAverageWindSpeed(), 'assets/icons/wind.png'),
          _buildWeatherMetric(
              'Pressure', _getAveragePressure(), 'assets/icons/air.png'),
        ],
      ),
    );
  }

  // Helper method to create metric display
  Widget _buildWeatherMetric(String label, double value, String iconPath) {
    return Column(
      children: [
        // Stack the icon above the label
        Image.asset(
          iconPath,
          height: 40,
          color: Colors.white,
        ),
        SizedBox(height: 8), // Space between the icon and label
        Text(
          '$label',
          style: GoogleFonts.josefinSans(
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4), // Space between label and value
        Text(
          '${value.toStringAsFixed(1)}',
          style: GoogleFonts.josefinSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the current weather condition
    String currentCondition = _getCurrentWeatherCondition();

    // Get the background color based on the current weather condition
    Color bgColor = _getBackgroundColor(currentCondition);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              // Row with back arrow and calendar icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _pickDate,
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Main content
              _filteredWeatherData.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Johor Bahru',
                                  style: GoogleFonts.josefinSans(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${DateFormat('MMMM dd, yyyy').format(_selectedDate)}',
                                  style: GoogleFonts.josefinSans(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildCurrentTemperature(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildMinMaxTemperature(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Hourly Forecast',
                                style: GoogleFonts.josefinSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.info_outline,
                                    color: Colors.white),
                                onPressed: _showIconInfo, // Show the popup
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

                        SizedBox(
                          height: 170,
                          child: ListView.builder(
                            controller:
                                _scrollController, // Attach ScrollController here
                            scrollDirection: Axis.horizontal,
                            itemCount: _filteredWeatherData.length,
                            itemBuilder: (context, index) {
                              final weather = _filteredWeatherData[index];
                              final currentHour =
                                  DateTime.now().hour; // Get the current hour
                              final weatherHour = weather.timestamp
                                  .hour; // Get the hour of this forecast item

                              return Container(
                                width: 110,
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: weatherHour == currentHour
                                      ? Colors.orange
                                      : Colors
                                          .blueAccent, // Highlight current hour
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${weather.temp_celsius.toStringAsFixed(1)}°C',
                                      style: GoogleFonts.josefinSans(
                                        fontSize: 22,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Image.asset(
                                      _getWeatherIconImagePath(weather),
                                      height: 60,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${DateFormat('h a').format(weather.timestamp)}',
                                      style: GoogleFonts.josefinSans(
                                        fontSize: 20,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 32),
                        // Weather Metrics and Show Chart Button Padding
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildWeatherMetrics(),
                        ),

// Add some space between Weather Metrics and Show Chart Button
                        SizedBox(
                            height:
                                20), // Adjust this value for desired spacing

                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WeatherGraphScreen(
                                    selectedDate: _selectedDate),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 60, vertical: 20),
                            backgroundColor:
                                Colors.yellow.shade700, // Button color
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // Rounded button
                            ),
                          ),
                          child: Text(
                            'Show Chart',
                            style: GoogleFonts.josefinSans(
                              fontSize: 22,
                              color:
                                  Colors.white, // Black text color for contrast
                            ),
                          ),
                        ),

// Add some space between Show Chart Button and 7-Day Forecast
                        SizedBox(
                            height:
                                20), // Adjust this value for desired spacing

// 7-Day Forecast Title
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '7-Day Forecast',
                              style: GoogleFonts.josefinSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),
                        SizedBox(
                          height: 260,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _getWeeklyForecast().length,
                            itemBuilder: (context, index) {
                              final forecast = _getWeeklyForecast()[index];
                              return Container(
                                width: 120,
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize
                                      .min, // Ensures no unnecessary space is taken up
                                  children: [
                                    // Date
                                    Text(
                                      DateFormat('MMM dd')
                                          .format(forecast['date']),
                                      style: GoogleFonts.josefinSans(
                                        fontSize: 20,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            8), // Add space between date and icon

                                    // Icon
                                    Image.asset(
                                      forecast['iconPath'],
                                      height: 60,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(
                                        height:
                                            8), // Add space between icon and avg temp

                                    // Avg Temp
                                    Text(
                                      ' ${forecast['avgTemp'].toStringAsFixed(1)}°C',
                                      style: GoogleFonts.josefinSans(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            8), // Add space between avg temp and min/max temp

                                    // Min/Max Temp
                                    Text(
                                      'Min: ${forecast['minTemp'].toStringAsFixed(1)}°C\nMax: ${forecast['maxTemp'].toStringAsFixed(1)}°C',
                                      style: GoogleFonts.josefinSans(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTemperature() {
    if (_filteredWeatherData.isEmpty) return Container();

    // Get the weather data for the current hour
    final currentHourWeather = _filteredWeatherData.firstWhere(
      (weather) => weather.timestamp.hour == DateTime.now().hour,
      orElse: () => _filteredWeatherData.first,
    );

    // Use the current hour's temperature
    double currentTemp = currentHourWeather.temp_celsius;

    // Calculate the average temperature for the selected day
    double avgTemp = _filteredWeatherData
            .map((weather) => weather.temp_celsius)
            .reduce((a, b) => a + b) /
        _filteredWeatherData.length;

    // Get the icon for the current weather conditions using the existing function
    String iconPath = _getWeatherIconImagePath(currentHourWeather);

    return Column(
      children: [
        // Current temperature
        Text(
          '${currentTemp.toStringAsFixed(1)}°C', // Display the current temperature
          style: GoogleFonts.josefinSans(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Image.asset(
          iconPath, // Display the weather icon based on conditions
          height: 100,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              'Icon missing',
              style: TextStyle(color: Colors.white),
            );
          },
        ),
        SizedBox(height: 16),
        // Average temperature
        Padding(
          padding: const EdgeInsets.only(
              top: 10.0), // Adjust this value for the desired space
          child: Text(
            'Avg: ${avgTemp.toStringAsFixed(1)}°C',
            style: GoogleFonts.josefinSans(
              fontSize: 22,
              color: Colors.white70,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMinMaxTemperature() {
    if (_filteredWeatherData.isEmpty) return Container();

    final minTemp = _filteredWeatherData.isNotEmpty
        ? _filteredWeatherData
            .map((weather) => weather.temp_celsius)
            .reduce((a, b) => a < b ? a : b)
        : 0.0; // Default value if there's no data
    final maxTemp = _filteredWeatherData.isNotEmpty
        ? _filteredWeatherData
            .map((weather) => weather.temp_celsius)
            .reduce((a, b) => a > b ? a : b)
        : 0.0; // Default value if there's no data

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'Min: ${minTemp.toStringAsFixed(1)}°C',
          style: GoogleFonts.josefinSans(
            fontSize: 20,
            color: Colors.white70,
          ),
        ),
        Text(
          'Max: ${maxTemp.toStringAsFixed(1)}°C',
          style: GoogleFonts.josefinSans(
            fontSize: 20,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  String _getWeatherIconImagePath(Weather weather) {
    // Determine if it is day or night based on time
    bool isDayTime = _isDayTime(weather.timestamp);

    // Conditions for daytime
    if (isDayTime) {
      if (weather.temp_celsius > 20 &&
          weather.humidity < 50 &&
          weather.wind_speed_mph <= 10) {
        return 'assets/icons/sun.png'; // Sunny during the day
      }
      if (weather.humidity >= 80 &&
          weather.temp_celsius < 20 &&
          weather.wind_speed_mph <= 10) {
        return 'assets/icons/light-rain-day.png'; // Light rain during the day
      }
      if (weather.humidity >= 50 &&
          weather.humidity < 80 &&
          weather.wind_speed_mph <= 10) {
        return 'assets/icons/cloudy.png'; // Cloudy during the day
      }
    } else {
      // Conditions for nighttime
      if (weather.humidity >= 80 && weather.wind_speed_mph <= 10) {
        return 'assets/icons/light-rain-night.png'; // Light rain at night
      }
      // Default nighttime icon if no specific conditions match
      return 'assets/icons/night.png';
    }

    // Additional condition for Windy, applicable both day and night
    if (weather.wind_speed_mph >= 15) {
      return 'assets/icons/windy.png'; // Windy
    }

    // Default icon if no other conditions match
    return isDayTime ? 'assets/icons/cloudy.png' : 'assets/icons/night.png';
  }

  bool _isDayTime(DateTime timestamp) {
    final hour = timestamp.hour;
    return hour >= 6 && hour < 18;
  }

  // Custom method to select an icon based on avg, min, and max temperature
  String _getDailyWeatherIcon(double avgTemp) {
    if (avgTemp > 30) {
      return 'assets/icons/sun.png'; // Hot/sunny icon
    } else if (avgTemp >= 20 && avgTemp <= 30) {
      return 'assets/icons/cloudy.png'; // Mild/cloudy icon
    } else if (avgTemp < 20) {
      return 'assets/icons/rain.png'; // Cool/rainy icon
    }
    return 'assets/icons/default.png'; // Default icon if no conditions match
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the controller
    super.dispose();
  }
}
