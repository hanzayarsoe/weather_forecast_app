import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_forecast/additional.dart';
import 'package:weather_forecast/hourly_forecast.dart';
import 'package:http/http.dart' as http;

import 'theme_model.dart';

class WeatherForecastHomePage extends StatefulWidget {
  const WeatherForecastHomePage({super.key});
  @override
  State<WeatherForecastHomePage> createState() =>
      _WeatherForecastHomePageState();
}

class _WeatherForecastHomePageState extends State<WeatherForecastHomePage> {
  //  get user location
  Future<String?> getUserCity() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return null;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      return placemarks[0].locality; // This will give you the city name
    } else {
      return null;
    }
  }

  // get api from openweatherorg
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String? userCity = await getUserCity();
      print(userCity);
      if (userCity != null) {
        final res = await http.get(Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$userCity&APPID=428297ac4f29c184baa6a54156ba03b0'));

        final data = jsonDecode(res.body);

        if (data['cod'] == '200') {
          debugPrint('successfully connected to weather API');
          return data;
        } else {
          debugPrint(throw 'An error occurred');
        }
      } else {
        debugPrint(throw 'Unable to get user location');
      }
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb),
            onPressed: () {
              Provider.of<ThemeModel>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('An Error Occured'),
            );
          }

          final data = snapshot.data!;
          final currenTemp = data['list'][0]['main']['temp'] - 273.15;
          final currenSky = data['list'][0]['weather'][0]['main'];
          final currenHumidity = data['list'][0]['main']['humidity'];
          final currenWinspeed = data['list'][0]['wind']['speed'];
          final currenPressure = data['list'][0]['main']['pressure'];
          final currenIcon = data['list'][0]['weather'][0]['icon'];
          final iconUrl = "http://openweathermap.org/img/w/$currenIcon.png";

          return Padding(
            padding: const EdgeInsets.all(15.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: double.infinity,

                // Main Widget
                child: Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Column(
                        children: [
                          Text(
                            '${currenTemp.toStringAsFixed(1)} °C',
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Image.network(
                            iconUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.fill,
                            // alignment: Alignment.center,
                          ),
                          Text(
                            '$currenSky',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              // Weather Forecast
              const Text(
                'Hourly Forecast',
                style: textStyle,
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    final hourlyForecast = data['list'][index + 1];
                    final hourlyImage = hourlyForecast['weather'][0]['icon'];
                    final hourlyImageUrl =
                        "https://openweathermap.org/img/w/$hourlyImage.png";
                    final hourlyTime = hourlyForecast['dt_txt'];
                    final date = DateTime.parse(hourlyTime);
                    final temp = hourlyForecast['main']['temp'] - 273.15;
                    return ForecastItems(
                      time: DateFormat.j().format(date),
                      image: Image.network(hourlyImageUrl),
                      temperature: '${temp.toStringAsFixed(1)}°C',
                    );
                  },
                ),
              ),

              // Additional information
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Additional Information',
                style: textStyle,
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Additional(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: currenHumidity.toString(),
                  ),
                  Additional(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value: currenWinspeed.toString(),
                  ),
                  Additional(
                    icon: Icons.umbrella,
                    label: 'Pressure',
                    value: currenPressure.toString(),
                  ),
                ],
              )
            ]),
          );
        },
      ),
    );
  }
}
