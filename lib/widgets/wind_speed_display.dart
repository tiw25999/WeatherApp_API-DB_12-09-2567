import 'package:flutter/material.dart';

class WindSpeedDisplay extends StatelessWidget {
  final String windSpeed;

  const WindSpeedDisplay({Key? key, required this.windSpeed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // แสดงความเร็วลมเป็นจำนวนเต็ม
    return Text(
      '${double.tryParse(windSpeed)?.toStringAsFixed(0) ?? 'N/A'} m/s', // แปลงเป็นจำนวนเต็ม
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
