class WeatherModel {
  // ─── Fields ─────────────────────────────────────────────────────────────────
  final String cityName;      
  final String country;       
  final double temperature;   
  final double tempMin;      
  final double tempMax;      
  final String condition;     
  final String description;   
  final int conditionCode;    

  // ─── Constructor ─────────────────────────────────────────────────────────────

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.description,
    required this.conditionCode,  //numeric code for determining which icon to be used
  });


  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    
    double kelvinToCelsius(dynamic k) => (k - 273.15).toDouble();

    return WeatherModel(

      cityName: json['name'],

     
      country: json['sys']['country'],

      temperature: kelvinToCelsius(json['main']['temp']),
      tempMin:     kelvinToCelsius(json['main']['temp_min']),
      tempMax:     kelvinToCelsius(json['main']['temp_max']),


      
      condition:     json['weather'][0]['main'],
      description:   json['weather'][0]['description'],
      conditionCode: (json['weather'][0]['id'] as num).toInt(),
    );
  }

  // ─── Helper: weather icon emoji ──────────────────────────────────────────────


  String get weatherIcon {
    
    return switch (conditionCode) {
      >= 200 && < 300 => '⛈️',   // thunderstorm
      >= 300 && < 400 => '🌦️',   // drizzle
      >= 500 && < 600 => '🌧️',   // rain
      >= 600 && < 700 => '❄️',   // snow
      >= 700 && < 800 => '🌫️',   // atmosphere (fog, haze, dust)
      800             => '☀️',   // clear sky
      >= 801 && < 900 => '☁️',   // clouds
      _               => '🌡️',   // fallback
    };
  }

  @override
  String toString() =>
    'WeatherModel(city: $cityName, temp: ${temperature.toStringAsFixed(1)}°C, '
    'condition: $condition)';
}
