import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? location;
  String? weather;
  String? temperature;
  List<WeatherForecast>? forecastList;

  final String apiKey =
      '83a55878f79e3eef5da0bd9a5f999740'; // Add your OpenWeatherMap API key here

  @override
  void initState() {
    super.initState();
    getLocationAndFetchWeather();
  }

  Future<void> getLocationAndFetchWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      fetchWeatherData(position.latitude, position.longitude);
      fetch5DayForecast(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        location = 'Location unavailable';
      });
    }
  }

  Future<void> fetchWeatherData(double latitude, double longitude) async {
    final apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print(response);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          setState(() {
            location = data['name']; // Extract the city name from the response
            // double tempKelvin = data['main']['temp']; // Temperature in Kelvin
            temperature = (data['main']['temp'] - 273.15)
                .toStringAsFixed(2); // Convert Kelvin to Celsius and round it
            weather = data['weather'][0]['main']; // Weather description
          });
        });
      } else {
        print('Failed to load weather data: ${response.statusCode}');
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      throw Exception('Failed to load weather data');
    }
  }

  Future<void> fetch5DayForecast(double latitude, double longitude) async {
    final apiUrl =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$apiKey';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          forecastList = (data['list'] as List)
              .map((item) => WeatherForecast.fromJson(item))
              .toList();
        });
      } else {
        print('Failed to load 5-day forecast data: ${response.statusCode}');
        throw Exception('Failed to load 5-day forecast data');
      }
    } catch (e) {
      print('Error fetching 5-day forecast data: $e');
      throw Exception('Failed to load 5-day forecast data');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    LinearGradient gradient;
    if (temperature != null) {
      double temp = double.parse(temperature!);
      if (temp < 25) {
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue, Colors.lightBlue],
        );
      } else if (temp < 33) {
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green, Colors.lightGreen],
        );
      } else {
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.amberAccent, Colors.orangeAccent],
        );
      }
    } else {
      gradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.grey, Colors.grey],
      );
    }
    String iconPath = '';

    // Determine the icon based on the weather condition
    switch (weather) {
      case 'Clouds':
        iconPath = 'assets/cloud1.png'; // Path to cloud icon
        break;
      case 'Rain':
        iconPath = 'assets/rain.png'; // Path to rain icon
        break;
      // Add cases for other weather conditions as needed
      default:
        iconPath = 'assets/cloud1.png'; // Default icon
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              Align(
                child: Container(
                  width: size.width,
                  height: 300,
                  color: Colors.cyan,
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(3, -1.3),
                child: Container(
                  width: size.width,
                  height: 300,
                  color: Colors.orange,
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
              ),
              SizedBox(
                width: size.width,
                height: size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Weather App',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        // const SizedBox(height: 8),
                        Text(
                          location ?? 'Loading...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          // border: Border.all(color: Colors.cyan, width: 1.0)
                        ),
                        child: Column(children: [
                          Image.asset(
                            iconPath,
                            width: 100, // Adjust the size of the icon as needed
                            height: 100,
                          ),
                          Center(
                            // ignore: unnecessary_null_comparison
                            child: temperature != null
                                ? Text(
                                    '$temperature°C',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 55,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : const CircularProgressIndicator(),
                          ),
                          Center(
                            child: Text(
                              weather ?? 'Loading...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          // gradient: gradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          // border: Border.all(color: Colors.cyan, width: 1.0)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Date',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Temperature',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Weather',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Expanded(
                              child: forecastList == null
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : ListView.builder(
                                      itemCount: forecastList!.length,
                                      itemBuilder: (context, index) {
                                        final forecast = forecastList![index];
                                        return ForecastItem(forecast: forecast);
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherForecast {
  final DateTime date;
  final String weather;
  final double temperature;

  WeatherForecast({
    required this.date,
    required this.weather,
    required this.temperature,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: DateTime.parse(json['dt_txt']),
      weather: json['weather'][0]['main'],
      temperature: (json['main']['temp'] - 273.15).toDouble(),
    );
  }
}

class ForecastItem extends StatelessWidget {
  final WeatherForecast forecast;

  const ForecastItem({Key? key, required this.forecast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3.0),
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              '${forecast.date.day}/${forecast.date.month}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            // const SizedBox(height: 8),
            Text(
              '${forecast.temperature.toStringAsFixed(2)}°C',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            // const SizedBox(height: 8),
            Text(
              forecast.weather,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
