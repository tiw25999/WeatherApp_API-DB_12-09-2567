import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
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
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String? selectedProvince;
  Map<String, dynamic>? weatherData;

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
    selectedProvince = provinces[0]; // Set default province
  }

  Future<void> fetchWeatherData() async {
    if (selectedProvince == null) {
      setState(() {
        weatherData = {"error": "กรุณาเลือกจังหวัดก่อน"};
      });
      return;
    }

    String date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String hour = DateFormat("H").format(DateTime.now());

    int parsedHour = int.tryParse(hour) ??
        0; // แปลงค่าจากสตริงเป็นจำนวนเต็ม และหากแปลงไม่ได้ให้ใช้ค่า 0 แทน

    String url =
        'https://data.tmd.go.th/nwpapi/v1/forecast/location/hourly/place?province=$selectedProvince&date=$date&hour=$parsedHour&duration=1&fields=tc,rh,ws10m,wd10m';

    final apiKey =
        'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImY3NDAzZjU3NTZjNTljZmI3NmViMmE3MmE4ZjE4NmE4MDU1NGEwZGM4NjJlNTI1NDgwZTk3NmRlNGE3ODBkNGFmNWRiMmNjNjk2NTk2ZGJlIn0.eyJhdWQiOiIyIiwianRpIjoiZjc0MDNmNTc1NmM1OWNmYjc2ZWIyYTcyYThmMTg2YTgwNTU0YTBkYzg2MmU1MjU0ODBlOTc2ZGU0YTc4MGQ0YWY1ZGIyY2M2OTY1OTZkYmUiLCJpYXQiOjE3MjUyMTIzMDcsIm5iZiI6MTcyNTIxMjMwNywiZXhwIjoxNzU2NzQ4MzA3LCJzdWIiOiIzNDE0Iiwic2NvcGVzIjpbXX0.SR_TtdFSx6iKbhkcmhRwnfVK3xD5Zex6cMR07wKglB4jdjdgS4_d9Imm0eiqsYFz_OttF095wYvCDbOjgpj7G-oBde4SzGhOF1DZW1CYd1lArS1HZzYNz17-JMBzj7P3CKypyzkoOyWAW9FLzldscsaZ3vzCxbyaroS6GRBRNgI1UK1CexekTwKRvFhHgQHjOxWF9aZMmN2cyR8PyNZfRunXSoZt_CgPBAR7hpSTvt7F23fYtTqI4M7UKjl7a11Qpw3szDcTgPjb8Ss-ZD3eX4eLQjGW8DzYj6B72BRoo81hPbkTKxL7DCywE9Y77NoE4DZKf59uXMwecA8AhuBvGtSYRDFJ8y_iUcqNPdDSFO39lVrj-9XKt4BdfQioV30XEGPph0gtg-TvhrUiLJhHyLt35oVt9byD3nSKjlptcVzk492VJnD-lRFWM3r_s1RhsrY9Kw6f27LRZTqq_cj6dy9eMDp4Jzci2an7EhtQeWUqqfAbdy3AuXr9MOePfnlkJrrq6Y3LgHIFMIwHIYn3L4JuVgNojPxXZXuecLOcfGkowiQjBf6QEWVsA6txtwmm6mO2XZbRVWUCL-VxRt2ZDwk8R8wZMR5e-TedWputjwIYM4Ltr9Pb88R_slJmQYqMZKRnzEh6MNNXf-9nDdRRw7VEGmIm4sgHPcXiJcEmz1c';

    try {
      print('Requesting URL: $url'); // Debug log

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'authorization': 'Bearer $apiKey',
        },
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data'); // Debug log
        setState(() {
          weatherData = (data['WeatherForecasts'] as List)
              .map((item) => {
                    "temperature": item['forecasts'][0]['data']['tc'],
                    "humidity": item['forecasts'][0]['data']['rh'],
                    "windSpeed": item['forecasts'][0]['data']['ws10m'],
                    "windDirection": item['forecasts'][0]['data']['wd10m'],
                  })
              .toList()
              .first;
        });
      } else {
        setState(() {
          weatherData = {
            "error": "Error fetching data: ${response.statusCode}"
          };
        });
        print('Error: ${response.statusCode}'); // Debug log
      }
    } catch (error) {
      setState(() {
        weatherData = {"error": "Error fetching data: $error"};
      });
      print('Exception: $error'); // Debug log
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: GestureDetector(
          onTap: () => _showProvincePicker(context),
          child: Container(
            width: 300,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
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
                Text(
                  weatherData?['temperature']?.toString() ?? 'N/A',
                  style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$selectedProvince\nประเทศไทย',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  DateFormat("HH:mm")
                      .format(DateTime.now()), // แสดงเวลาปัจจุบันในรูปแบบ HH:mm
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text('Temperature: ${weatherData?['temperature'] ?? 'N/A'}°C'),
                Text('Humidity: ${weatherData?['humidity'] ?? 'N/A'}%'),
                Text('Wind Speed: ${weatherData?['windSpeed'] ?? 'N/A'} m/s'),
                Text(
                    'Wind Direction: ${weatherData?['windDirection'] ?? 'N/A'}°'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProvincePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        List<String> filteredProvinces = provinces;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('เลือกจังหวัด'),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'ค้นหาจังหวัด',
                        prefixIcon: Icon(Icons.search, color: Colors.black),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                          filteredProvinces = provinces
                              .where(
                                  (province) => province.contains(searchQuery))
                              .toList();
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 300, // Set a height to the list
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredProvinces.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(filteredProvinces[index]),
                            onTap: () {
                              setState(() {
                                selectedProvince = filteredProvinces[index];
                                weatherData = null;
                              });
                              fetchWeatherData();
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
