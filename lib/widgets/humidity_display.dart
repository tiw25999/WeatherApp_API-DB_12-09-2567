import 'package:flutter/material.dart';

class HumidityDisplay extends StatelessWidget {
  final String humidity;

  const HumidityDisplay({Key? key, required this.humidity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // แสดงความชื้นเป็นจำนวนเต็ม
    return Text(
      '${double.tryParse(humidity)?.toStringAsFixed(0) ?? 'N/A'}%', // แปลงเป็นจำนวนเต็ม
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
