import 'package:flutter/material.dart';

class TemperatureDisplay extends StatelessWidget {
  final String temperature;

  const TemperatureDisplay({Key? key, required this.temperature})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '$temperature°C',
      style: const TextStyle(
        fontSize: 60,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
