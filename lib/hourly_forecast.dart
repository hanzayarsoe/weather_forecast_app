import 'package:flutter/material.dart';

class ForecastItems extends StatelessWidget {
  const ForecastItems(
      {super.key,
      required this.time,
      required this.temperature,
      required this.image});
  final Image image;
  final String time;
  final String temperature;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        child: Column(
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            image,
            Text(
              temperature,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
