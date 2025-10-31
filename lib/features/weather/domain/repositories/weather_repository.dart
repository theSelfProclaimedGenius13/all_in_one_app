import '../weather.dart';

abstract class WeatherRepository {
  Future<Weather> getWeather(String cityName);

  Future<void> saveLastSearchedCity(String cityName);

  Future<String?> getLastSearchedCity();
}
