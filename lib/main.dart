import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_forecast/weather_forecast.dart';

import 'theme_model.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => ThemeModel(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather Forecast',
      theme: Provider.of<ThemeModel>(context).getTheme(),
      home: const WeatherForecastHomePage(),
    );
  }
}
