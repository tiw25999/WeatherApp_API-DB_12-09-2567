class WeatherModel {
  final double? temperature;
  final double? humidity;
  final double? windSpeed;

  WeatherModel({
    this.temperature,
    this.humidity,
    this.windSpeed,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: json['tc'] != null ? json['tc'].toDouble() : null,
      humidity: json['rh'] != null ? json['rh'].toDouble() : null,
      windSpeed: json['ws10m'] != null ? json['ws10m'].toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tc': temperature,
      'rh': humidity,
      'ws10m': windSpeed,
    };
  }
}
