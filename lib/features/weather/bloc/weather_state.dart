import 'package:equatable/equatable.dart';

import '../domain/weather.dart';

enum WeatherStatus { initial, loading, success, failure }

class WeatherState extends Equatable {
  final WeatherStatus status;
  final Weather? weather; // Can be null
  final String? errorMessage;

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather,
    this.errorMessage,
  });

  WeatherState copyWith({
    WeatherStatus? status,
    Weather? weather,
    String? errorMessage,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      errorMessage: errorMessage, // Don't carry over old errors
    );
  }

  @override
  List<Object?> get props => [status, weather, errorMessage];
}
