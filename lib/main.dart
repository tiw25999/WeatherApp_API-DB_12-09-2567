import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:firebase_core/firebase_core.dart'; // Import Firebase
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'features/auth/Forgot.dart';
import 'features/auth/Login.dart';
import 'features/auth/Newpass.dart';
import 'features/auth/Register.dart';
import 'features/forecast/SevenDayForecastScreen.dart';
import 'features/settings/SettingsScreen.dart';
import 'firebase_options.dart'; // Import Firebase Options
import 'models/forecast_model.dart'; // Import ForecastModel
import 'services/location_service.dart'; // Import Location Service
import 'services/weather_service.dart'; // Import Weather Service
import 'widgets/humidity_display.dart'; // Import HumidityDisplay
import 'widgets/province_picker.dart'; // Import ProvincePicker
import 'widgets/temperature_display.dart'; // Import TemperatureDisplay
import 'widgets/wind_speed_display.dart'; // Import WindSpeedDisplay

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('th_TH', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(), // เริ่มที่ WeatherScreen
      routes: {
        '/settings': (context) => SettingsScreen(),
        '/login': (context) => Login(
              onLoginSuccess: () {
                print('Login success');
                Navigator.pop(context);
              },
            ),
        '/register': (context) => Register(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/newpass': (context) => const NewPasswordScreen(),
      },
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String? selectedProvince;
  Map<String, dynamic>? weatherData;
  String? dailyWeather;
  List<Map<String, String>> hourlyData = [];

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Firestore instance
  final List<String> provinces = [
    'กรุงเทพมหานคร',
    'กระบี่',
    'กาญจนบุรี',
    'กาฬสินธุ์',
    'กำแพงเพชร',
    'ขอนแก่น',
    'จันทบุรี',
    'ฉะเชิงเทรา',
    'ชลบุรี',
    'ชัยนาท',
    'ชัยภูมิ',
    'ชุมพร',
    'เชียงใหม่',
    'เชียงราย',
    'ตรัง',
    'ตราด',
    'ตาก',
    'นครนายก',
    'นครปฐม',
    'นครพนม',
    'นครราชสีมา',
    'นครศรีธรรมราช',
    'นครสวรรค์',
    'นนทบุรี',
    'นราธิวาส',
    'น่าน',
    'บึงกาฬ',
    'บุรีรัมย์',
    'ปทุมธานี',
    'ประจวบคีรีขันธ์',
    'ปราจีนบุรี',
    'ปัตตานี',
    'พระนครศรีอยุธยา',
    'พังงา',
    'พัทลุง',
    'พิจิตร',
    'พิษณุโลก',
    'เพชรบุรี',
    'เพชรบูรณ์',
    'แพร่',
    'พะเยา',
    'ภูเก็ต',
    'มหาสารคาม',
    'มุกดาหาร',
    'แม่ฮ่องสอน',
    'ยะลา',
    'ยโสธร',
    'ร้อยเอ็ด',
    'ระนอง',
    'ระยอง',
    'ราชบุรี',
    'ลพบุรี',
    'ลำปาง',
    'ลำพูน',
    'เลย',
    'ศรีสะเกษ',
    'สกลนคร',
    'สงขลา',
    'สตูล',
    'สมุทรปราการ',
    'สมุทรสงคราม',
    'สมุทรสาคร',
    'สระแก้ว',
    'สระบุรี',
    'สิงห์บุรี',
    'สุโขทัย',
    'สุพรรณบุรี',
    'สุราษฎร์ธานี',
    'สุรินทร์',
    'หนองคาย',
    'หนองบัวลำภู',
    'อ่างทอง',
    'อุดรธานี',
    'อุทัยธานี',
    'อุตรดิตถ์',
    'อุบลราชธานี',
    'อำนาจเจริญ'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await LocationService.getCurrentLocation();
      String? province = await LocationService.getProvinceFromCoordinates(
          position.latitude, position.longitude);

      setState(() {
        selectedProvince = province ?? provinces.first;
      });

      await _fetchWeatherData();
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        selectedProvince = provinces.first;
      });
    }
  }

  Future<void> _fetchWeatherData() async {
    if (selectedProvince != null) {
      var dailyResponse =
          await WeatherService.fetchDailyWeather(selectedProvince!);
      print('Daily Response: $dailyResponse');
      var hourlyResponse =
          await WeatherService.fetchHourlyWeather(selectedProvince!);
      print('Hourly Response: $hourlyResponse');

      if (dailyResponse != null && dailyResponse['WeatherForecasts'] != null) {
        List forecasts = dailyResponse['WeatherForecasts'][0]['forecasts'];

        DateTime today = DateTime.now();
        var todayForecast = forecasts.firstWhere(
            (forecast) => DateTime.parse(forecast['time']).day == today.day,
            orElse: () => null);

        if (todayForecast != null) {
          setState(() {
            DateTime date = DateTime.parse(todayForecast['time']);
            String dayOfWeek = DateFormat('EEEE', 'th_TH').format(date);

            // ตรวจสอบว่า tc_max มีค่าหรือไม่
            var maxTempData = todayForecast['data']['tc_max'];
            int maxTemp = maxTempData != null ? maxTempData.round() : 0;

            dailyWeather = '$dayOfWeek ${maxTemp > 0 ? maxTemp : '-'}°C';
          });
        } else {
          print('No weather data found for today');
        }
      }

      if (hourlyResponse != null &&
          hourlyResponse['WeatherForecasts'] != null) {
        hourlyData =
            (hourlyResponse['WeatherForecasts'][0]['forecasts'] as List)
                .map((forecast) {
          var hourlyForecast = ForecastModel.fromJson(forecast);
          DateTime dateTime = DateTime.parse(hourlyForecast.time).toLocal();
          String formattedTime = DateFormat("HH:mm").format(dateTime);

          double temperature = hourlyForecast.weather.temperature ?? 0.0;
          double humidity = hourlyForecast.weather.humidity ?? 0.0;
          double windSpeed = hourlyForecast.weather.windSpeed ?? 0.0;

          return {
            "time": formattedTime,
            "temperature": "${temperature.toStringAsFixed(0)}",
            "humidity": humidity.toStringAsFixed(2),
            "windSpeed": windSpeed.toStringAsFixed(2)
          };
        }).toList();

        if (hourlyData.isNotEmpty) {
          setState(() {
            weatherData = {
              "temperature": hourlyData[0]['temperature'],
              "humidity": hourlyData[0]['humidity'],
              "windSpeed": hourlyData[0]['windSpeed'],
            };
          });
        } else {
          print('No hourly data available');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () => _showProvincePicker(context),
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TemperatureDisplay(
                          temperature: weatherData?['temperature'] ?? 'N/A',
                        ),
                        Text(
                          selectedProvince != null
                              ? '$selectedProvince\nประเทศไทย'
                              : 'ไม่พบจังหวัด',
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          DateFormat("HH:mm").format(DateTime.now()),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // แสดงผลข้อมูลรายชั่วโมง
            Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: hourlyData.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      childAspectRatio: 1 / 1.5,
                    ),
                    itemBuilder: (context, index) {
                      String hour = hourlyData[index]['time']!;
                      String temperature = hourlyData[index]['temperature']!;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(hour, style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 2),
                          Text('$temperature°',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            // แสดงผลความชื้นและความเร็วลม
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container สำหรับความชื้น
                Container(
                  width: 140,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('ความชื้น', style: TextStyle(fontSize: 16)),
                      HumidityDisplay(
                        humidity: weatherData?['humidity'] ?? 'N/A',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Container สำหรับความเร็วลม
                Container(
                  width: 140,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('ความเร็วลม', style: TextStyle(fontSize: 16)),
                      WindSpeedDisplay(
                        windSpeed: weatherData?['windSpeed'] ?? 'N/A',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SevenDayForecastScreen(province: selectedProvince!),
                  ),
                );
              },
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  dailyWeather ?? 'Loading daily data...',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProvincePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return ProvincePicker(
          provinces: provinces,
          onProvinceSelected: (String selected) {
            setState(() {
              selectedProvince = selected;
              weatherData = null;
              dailyWeather = null;
            });
            _fetchWeatherData();
          },
        );
      },
    );
  }
}
