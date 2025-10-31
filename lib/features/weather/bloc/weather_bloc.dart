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
