import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final String cityName;
  final double temperature; // We'll store it in Celsius
  final String condition;
  final String icon;

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.icon,
  });

  // This factory constructor is the "parser"
  // It knows how to read the JSON from OpenWeatherMap
  factory Weather.fromJson(Map<String, dynamic> json) {
    // Helper function to convert Kelvin to Celsius
    double kelvinToCelsius(double kelvin) {
      return kelvin - 273.15;
    }

    return Weather(
      // json['name'] is at the top level
      cityName: json['name'] as String,

      // json['main']['temp'] is nested
      temperature: kelvinToCelsius((json['main']['temp'] as num).toDouble()),

      // json['weather'][0]['main'] is in a nested list
      condition: json['weather'][0]['main'] as String,
      icon: json['weather'][0]['icon'] as String,
    );
  }

  @override
  List<Object?> get props => [cityName, temperature, condition, icon];
}
