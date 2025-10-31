import '../weather.dart';

abstract class WeatherRepository {
  Future<Weather> getWeather(String cityName);
}
