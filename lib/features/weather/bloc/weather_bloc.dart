import 'package:all_in_one_app/features/weather/bloc/weather_event.dart';
import 'package:all_in_one_app/features/weather/bloc/weather_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/repositories/weather_repository.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository _weatherRepository;

  WeatherBloc({required WeatherRepository weatherRepository})
    : _weatherRepository = weatherRepository,
      super(const WeatherState()) {
    on<FetchWeather>(_onFetchWeather);
    on<LoadLastCity>(_onLoadLastCity);
  }

  Future<void> _onLoadLastCity(
    LoadLastCity event,
    Emitter<WeatherState> emit,
  ) async {
    // Get the saved city from the repository
    final lastCity = await _weatherRepository.getLastSearchedCity();

    if (lastCity != null) {
      // If we have a saved city, automatically fetch its weather
      add(FetchWeather(lastCity));
    }
    // If we don't have one, do nothing. The state stays 'initial'.
  }

  Future<void> _onFetchWeather(
    FetchWeather event,
    Emitter<WeatherState> emit,
  ) async {
    // 1. Emit the Loading state
    emit(state.copyWith(status: WeatherStatus.loading));

    try {
      // 2. Call the repository
      final weather = await _weatherRepository.getWeather(event.cityName);
      await _weatherRepository.saveLastSearchedCity(event.cityName);
      // 3. Emit the Success state with the data
      emit(state.copyWith(status: WeatherStatus.success, weather: weather));
    } catch (e) {
      // 4. Emit the Failure state with the error
      emit(
        state.copyWith(
          status: WeatherStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
