
// PURPOSE: Handle all communication with the OpenWeather API.
//   1. Build the correct URL
//   2. Send the HTTP GET request
//   3. Check the response status
//   4. Decode the JSON body
//   5. Return a WeatherModel (or throw a descriptive error)

// ─── Imports ──────────────────────────────────────────────────────────────────
import 'dart:convert';

// 'package:http/http.dart' is the third-party package we added in pubspec.yaml.
// We alias it as 'http' so we can write http.get() — easier to read.
import 'package:http/http.dart' as http;

// Our own model — needed to create and return a WeatherModel object.
import '../model/weather_model.dart';

// ─── Class ────────────────────────────────────────────────────────────────────

class WeatherService {
  // ── API configuration ────────────────────────────────────────────────────────

  static const String _apiKey  = 'c81cc847eca8a7e6139843c21c866856';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';


  Future<WeatherModel> fetchWeather(String cityName) async {

    final Uri url = Uri.parse('$_baseUrl?q=$cityName&appid=$_apiKey');

   
    final http.Response response = await http.get(url);

    // Check the HTTP status code ────────────────────────────────────
    //
    // HTTP status codes you'll see with OpenWeather:
    //   200 = OK (success)
    //   401 = Unauthorized (wrong or inactive API key)
    //   404 = Not Found (city name doesn't exist)
    //   429 = Too Many Requests (free tier limit hit)
    //   500 = Internal Server Error (their problem, not yours)

    if (response.statusCode == 200) {
      // ── Step 4: Decode the JSON ───────────────────────────────────────────────
      //
      // response.body is a raw String 

      final Map<String, dynamic> jsonData =
          jsonDecode(response.body) as Map<String, dynamic>;

      return WeatherModel.fromJson(jsonData);

    } else if (response.statusCode == 401) {
      // Specific error for bad API key — helps the developer debug faster
      throw Exception(
        'Invalid API key (401). '
        'Check that YOUR_API_KEY_HERE is replaced with your real key, '
        'and that it has been active for at least 2 hours.',
      );

    } else if (response.statusCode == 404) {
      // City not found — user-facing error, pass it through clearly
      throw Exception(
        'City "$cityName" not found (404). '
        'Check the spelling or try a nearby major city.',
      );

    } else {
      // Catch-all for unexpected errors (429, 500, etc.)
      throw Exception(
        'Weather request failed. '
        'Status code: ${response.statusCode}. '
        'Body: ${response.body}',
      );
    }
  }
}
