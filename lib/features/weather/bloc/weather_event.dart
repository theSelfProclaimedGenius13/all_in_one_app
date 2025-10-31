import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();
  @override
  List<Object> get props => [];
}

// The only event: user searches for a city
class FetchWeather extends WeatherEvent {
  final String cityName;
  const FetchWeather(this.cityName);
  @override
  List<Object> get props => [cityName];
}

class LoadLastCity extends WeatherEvent {}
