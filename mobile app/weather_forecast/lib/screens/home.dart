import 'package:flutter/material.dart';
import 'weather_screen.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class HomePage extends StatelessWidget {
  // Function to show the loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: CircularProgressIndicator(), // This shows the loading spinner
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1), // Dark blue for top part
              Color(0xFF1976D2), // Lighter blue for bottom part
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Use local asset icon
              Image.asset(
                'assets/icons/app.png', // Path to your icon
                width: 120,
                height: 120,
              ),
              SizedBox(height: 40),
              // "Weather Forecast" Text
              Text(
                'CLIMA\nVIEW',
                textAlign: TextAlign.center,
                style: GoogleFonts.josefinSans(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              // Subheading or description text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Stay ahead of the weather with accurate forecasts and real-time updates. Plan your day with confidence, no matter where you are.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.josefinSans(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
              ),
              SizedBox(height: 40),
              // "Get Start" Button
              ElevatedButton(
                onPressed: () async {
                  // Show loading dialog
                  _showLoadingDialog(context);

                  // Simulate a loading process (replace with your actual async operation)
                  await Future.delayed(Duration(seconds: 2));

                  // Close the loading dialog
                  Navigator.pop(context);

                  // Navigate to the next screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WeatherScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                  backgroundColor: Colors.yellow.shade700, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded button
                  ),
                ),
                child: Text(
                  'Get Start',
                  style: GoogleFonts.josefinSans(
                    fontSize: 22,
                    color: Colors.white, // Black text color for contrast
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
