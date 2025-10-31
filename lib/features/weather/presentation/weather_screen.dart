import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:all_in_one_app/features/weather/bloc/weather_bloc.dart';
import 'package:all_in_one_app/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:all_in_one_app/features/weather/domain/weather.dart';

import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';

/// --- 1. The Main Widget (Provides the BLoC) ---
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherBloc(
        // We create and provide the repository right here
        weatherRepository: WeatherRepositoryImpl(),
      ),
      child: const _WeatherView(),
    );
  }
}

/// --- 2. The View Widget (A StatefulWidget) ---
/// We use a StatefulWidget to manage the TextEditingController
class _WeatherView extends StatefulWidget {
  const _WeatherView();

  @override
  State<_WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<_WeatherView> {
  // A controller for the search bar
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper to submit the search
  void _submitSearch() {
    if (_searchController.text.isNotEmpty) {
      // Find the BLoC and add the FetchWeather event
      context.read<WeatherBloc>().add(FetchWeather(_searchController.text));

      // Hide the keyboard
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Note: No AppBar, this screen is part of the ShellRoute
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 3. The Search Bar ---
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter City Name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _submitSearch,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) =>
                  _submitSearch(), // Allow submitting from keyboard
            ),
            const SizedBox(height: 24),

            // --- 4. The Main Content Area ---
            Expanded(
              child: Center(
                // This BlocBuilder will rebuild the content
                // based on the WeatherState
                child: BlocBuilder<WeatherBloc, WeatherState>(
                  builder: (context, state) {
                    // --- Initial State ---
                    if (state.status == WeatherStatus.initial) {
                      return const Text(
                        'Search for a city to get the weather',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      );
                    }

                    // --- Loading State ---
                    if (state.status == WeatherStatus.loading) {
                      return const CircularProgressIndicator();
                    }

                    // --- Failure State ---
                    if (state.status == WeatherStatus.failure) {
                      return Text(
                        'Failed to fetch weather:\n${state.errorMessage}',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      );
                    }

                    // --- Success State ---
                    if (state.status == WeatherStatus.success &&
                        state.weather != null) {
                      return _WeatherDisplay(weather: state.weather!);
                    }

                    // Should never happen, but it's a good fallback
                    return const Text('Something went wrong.');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// --- 5. Helper Widget to Display the Weather ---
class _WeatherDisplay extends StatelessWidget {
  final Weather weather;

  const _WeatherDisplay({required this.weather});

  // Helper to get the weather icon URL
  String _getWeatherIconUrl(String iconCode) {
    // OpenWeatherMap provides icons at this URL
    return 'https://openweathermap.org/img/wn/$iconCode@4x.png';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // City Name
        Text(
          weather.cityName,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),

        // Weather Icon
        Image.network(
          _getWeatherIconUrl(weather.icon),
          width: 150,
          height: 150,
        ),

        // Temperature
        Text(
          // .toStringAsFixed(1) shows one decimal place (e.g., "17.3")
          '${weather.temperature.toStringAsFixed(1)} °C',
          style: const TextStyle(fontSize: 50, fontWeight: FontWeight.w300),
        ),

        // Condition
        Text(
          weather.condition,
          style: const TextStyle(fontSize: 24, color: Colors.grey),
        ),
      ],
    );
  }
}
