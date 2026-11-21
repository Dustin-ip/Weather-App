import 'package:flutter/material.dart';
import '../service/weather_service.dart';
import '../model/weather_model.dart';

// ─── StatefulWidget shell ─────────────────────────────────────────────────────
// HomeScreen extends StatefulWidget because our screen CHANGES:
//   - initially empty
//   - shows a spinner while loading
//   - shows weather data after success
//   - shows an error after failure

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── State variables ────────────────────────────────────────────────────────


  WeatherModel? _weather;   // null until a successful API response arrives
  bool _isLoading = false;  // true while the HTTP request is in flight
  String? _errorMessage;    // null unless the request failed

  // ── Services and controllers ───────────────────────────────────────────────

  // WeatherService is our HTTP worker — it fetches and parses weather data.
  final WeatherService _weatherService = WeatherService();


  // Calling _cityController.text gives us whatever the user typed.
  final TextEditingController _cityController = TextEditingController();

  // ── dispose() ─────────────────────────────────────────────────────────────
  //
  // dispose() is called when this widget is permanently removed from the tree
  // We MUST dispose controllers to free memory.

  @override
  void dispose() {
    _cityController.dispose();  // release the TextEditingController
    super.dispose();            // always call super.dispose() last
  }

  // ── _searchWeather() ──────────────────────────────────────────────────────

  // This is an async function because it awaits a network response.

  Future<void> _searchWeather() async {
    // Trim whitespace from whatever the user typed
    final String cityName = _cityController.text.trim();

    // Guard: do nothing if the field is empty
    if (cityName.isEmpty) return;

    // ── setState() call #1 — enter loading state ───────────────────────────
    //
    // setState() does two things:
    //   1. Runs the callback, which updates our variables.
    //   2. Schedules a rebuild of this widget (calls build() again).
    //
    // After this setState(), build() sees _isLoading == true and renders
    // the CircularProgressIndicator instead of the weather card.

    setState(() {
      _isLoading = true;
      _errorMessage = null;   // clear any previous error
      _weather = null;        // clear any previous weather data
    });

    // ── Try the HTTP request ───────────────────────────────────────────────

    try {
      // await pauses here until fetchWeather() resolves its Future.

      final WeatherModel data =
          await _weatherService.fetchWeather(cityName);

      // ── setState() call #2 — show the results ─────────────────────────────

      setState(() {
        _weather = data;
        _isLoading = false;
      });

    } catch (e) {
      // ── setState() call #2 (error path) — show the error ──────────────────
      //
      // e.toString() converts the Exception object to a human-readable string.
      // build() will see _errorMessage != null and render the error widget.

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ── build() ───────────────────────────────────────────────────────────────
  //
  // build() is called by Flutter every time setState() runs.
  // It describes what the screen should look like RIGHT NOW given
  // the current values of _weather, _isLoading, and _errorMessage.

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Kuya Kim, ano na?'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,   // makes the title text white
      ),

     
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Search section ───────────────────────────────────────────────
            _buildSearchSection(),


            const SizedBox(height: 24),


            if (_isLoading) _buildLoadingWidget(),
            if (_errorMessage != null) _buildErrorWidget(_errorMessage!),
            if (_weather != null) _buildWeatherCard(_weather!),
          ],
        ),
      ),
    );
  }

  // ─── _buildSearchSection ──────────────────────────────────────────────────
  

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // TextField: the text input box
        // decoration: controls the visual appearance (label, border, icon)
        TextField(
          controller: _cityController,

          // textInputAction changes the keyboard's return key label.
          // .search shows a magnifier icon — feels natural for a search field.
          textInputAction: TextInputAction.search,

          // onSubmitted fires when the user taps the keyboard's search key.
          // We ignore the passed value and use _cityController.text instead.
          onSubmitted: (_) => _searchWeather(),

          // InputDecoration controls how the field looks
          decoration: InputDecoration(
            // prefixIcon adds an icon inside the left edge of the field
            prefixIcon: const Icon(Icons.search),
            // OutlineInputBorder gives the field a full rectangular border
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ElevatedButton: a raised, filled button
        // onPressed: the function to call when tapped
        // child: the widget shown inside the button (usually a Text)
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _searchWeather,
          // When _isLoading is true, onPressed = null, which DISABLES the button.
          // Flutter automatically greys it out — built-in UX for free.

          icon: const Icon(Icons.cloud_download_outlined),
          label: const Text('Get Weather'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  // ─── _buildLoadingWidget ──────────────────────────────────────────────────
  //
  // Shown while the HTTP request is in flight.
  // Center: centers its child both horizontally and vertically.
  // CircularProgressIndicator: the spinning wheel.

  Widget _buildLoadingWidget() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Fetching weather…',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ─── _buildErrorWidget ────────────────────────────────────────────────────
  //
  // The ! after _errorMessage is the null-assertion operator.
  // We only call this method when _errorMessage != null, so the ! is safe here.
  // It tells Dart: "I know this isn't null — trust me."

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  // ─── _buildWeatherCard ────────────────────────────────────────────────────
  //
  // The main weather display. Only called when _weather is not null.
  // We use the ! operator (weather!) because we've already null-checked.

  Widget _buildWeatherCard(WeatherModel weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Main card (city + temperature + condition) ─────────────────────
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // City + country
              Text(
                '${weather.cityName}, ${weather.country}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // Weather icon from our computed property
              Text(
                weather.weatherIcon,
                style: const TextStyle(fontSize: 64),
              ),

              // Temperature — toStringAsFixed(1) shows one decimal place: 31.0
              Text(
                '${weather.temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              // Condition (e.g. "Clouds") — capitalize first letter
              Text(
                weather.description[0].toUpperCase() +
                    weather.description.substring(1),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 8),

              // High / Low
              Text(
                'H: ${weather.tempMax.toStringAsFixed(0)}°  '
                'L: ${weather.tempMin.toStringAsFixed(0)}°',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ), 
      ] 
    );
  }
}
