import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart'; // นำเข้าการจัดการวันที่ในท้องถิ่น
import 'package:intl/intl.dart';

import 'SevenDayForecastScreen.dart';

void main() async {
  // Initialize localization for dates
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
  List<Map<String, String>> hourlyData = [];
  String? dailyWeather; // สำหรับเก็บข้อมูลพยากรณ์อากาศรายวัน

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
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      print('Current location: ${position.latitude}, ${position.longitude}');

      String? province = await getProvinceFromCoordinates(
          position.latitude, position.longitude);

      setState(() {
        selectedProvince = province ?? 'ไม่พบจังหวัด';
      });

      fetchWeatherDataByProvince(selectedProvince!);
      fetchHourlyWeatherData(selectedProvince!);
      fetchDailyWeatherData(selectedProvince!); // เรียกฟังก์ชันดึงข้อมูลรายวัน
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<String?> getProvinceFromCoordinates(double lat, double lon) async {
    final apiKey =
        'pk.0118ee540ae83cd72685cbb10ef7cfd2'; // ใส่ API Key ของคุณที่นี่
    final url =
        'https://us1.locationiq.com/v1/reverse.php?key=$apiKey&lat=$lat&lon=$lon&format=json';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('LocationIQ response: $data'); // Debug log
        String? province = data['address']['province'];

        // แผนที่ชื่อจังหวัดภาษาอังกฤษเป็นภาษาไทย
        Map<String, String> provinceMapping = {
          'Bangkok Province': 'กรุงเทพมหานคร',
          'Krabi Province': 'กระบี่',
          'Kanchanaburi Province': 'กาญจนบุรี',
          'Kalasin Province': 'กาฬสินธุ์',
          'Kamphaeng Phet Province': 'กำแพงเพชร',
          'Khon Kaen Province': 'ขอนแก่น',
          'Chanthaburi Province': 'จันทบุรี',
          'Chachoengsao Province': 'ฉะเชิงเทรา',
          'Chonburi Province': 'ชลบุรี',
          'Chai Nat Province': 'ชัยนาท',
          'Chaiyaphum Province': 'ชัยภูมิ',
          'Chumphon Province': 'ชุมพร',
          'Chiang Mai Province': 'เชียงใหม่',
          'Chiang Rai Province': 'เชียงราย',
          'Trang Province': 'ตรัง',
          'Trat Province': 'ตราด',
          'Tak Province': 'ตาก',
          'Nakhon Nayok Province': 'นครนายก',
          'Nakhon Pathom Province': 'นครปฐม',
          'Nakhon Phanom Province': 'นครพนม',
          'Nakhon Ratchasima Province': 'นครราชสีมา',
          'Nakhon Si Thammarat Province': 'นครศรีธรรมราช',
          'Nakhon Sawan Province': 'นครสวรรค์',
          'Nonthaburi Province': 'นนทบุรี',
          'Narathiwat Province': 'นราธิวาส',
          'Nan Province': 'น่าน',
          'Bueng Kan Province': 'บึงกาฬ',
          'Buriram Province': 'บุรีรัมย์',
          'Pathum Thani Province': 'ปทุมธานี',
          'Prachuap Khiri Khan Province': 'ประจวบคีรีขันธ์',
          'Prachinburi Province': 'ปราจีนบุรี',
          'Pattani Province': 'ปัตตานี',
          'Ayutthaya Province': 'พระนครศรีอยุธยา',
          'Phang Nga Province': 'พังงา',
          'Phatthalung Province': 'พัทลุง',
          'Phichit Province': 'พิจิตร',
          'Phitsanulok Province': 'พิษณุโลก',
          'Phetchaburi Province': 'เพชรบุรี',
          'Phetchabun Province': 'เพชรบูรณ์',
          'Phrae Province': 'แพร่',
          'Phayao Province': 'พะเยา',
          'Phuket Province': 'ภูเก็ต',
          'Maha Sarakham Province': 'มหาสารคาม',
          'Mukdahan Province': 'มุกดาหาร',
          'Mae Hong Son Province': 'แม่ฮ่องสอน',
          'Yala Province': 'ยะลา',
          'Yasothon Province': 'ยโสธร',
          'Roi Et Province': 'ร้อยเอ็ด',
          'Ranong Province': 'ระนอง',
          'Rayong Province': 'ระยอง',
          'Ratchaburi Province': 'ราชบุรี',
          'Lopburi Province': 'ลพบุรี',
          'Lampang Province': 'ลำปาง',
          'Lamphun Province': 'ลำพูน',
          'Loei Province': 'เลย',
          'Si Sa Ket Province': 'ศรีสะเกษ',
          'Sakon Nakhon Province': 'สกลนคร',
          'Songkhla Province': 'สงขลา',
          'Satun Province': 'สตูล',
          'Samut Prakan Province': 'สมุทรปราการ',
          'Samut Songkhram Province': 'สมุทรสงคราม',
          'Samut Sakhon Province': 'สมุทรสาคร',
          'Sa Kaeo Province': 'สระแก้ว',
          'Saraburi Province': 'สระบุรี',
          'Sing Buri Province': 'สิงห์บุรี',
          'Sukhothai Province': 'สุโขทัย',
          'Suphan Buri Province': 'สุพรรณบุรี',
          'Surat Thani Province': 'สุราษฎร์ธานี',
          'Surin Province': 'สุรินทร์',
          'Nong Khai Province': 'หนองคาย',
          'Nong Bua Lamphu Province': 'หนองบัวลำภู',
          'Ang Thong Province': 'อ่างทอง',
          'Udon Thani Province': 'อุดรธานี',
          'Uthai Thani Province': 'อุทัยธานี',
          'Uttaradit Province': 'อุตรดิตถ์',
          'Ubon Ratchathani Province': 'อุบลราชธานี',
          'Amnat Charoen Province': 'อำนาจเจริญ'
        };

        // แปลงชื่อจังหวัดเป็นภาษาไทย
        if (province != null && provinceMapping.containsKey(province)) {
          province = provinceMapping[province];
        } else {
          province = 'ไม่พบจังหวัด';
        }

        return province;
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }

  Future<void> fetchWeatherDataByProvince(String province) async {
    String date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String hour = DateFormat("H").format(DateTime.now());

    int parsedHour = int.tryParse(hour) ?? 0;

    String url =
        'https://data.tmd.go.th/nwpapi/v1/forecast/location/hourly/place?province=$province&date=$date&hour=$parsedHour&duration=1&fields=tc,rh,ws10m,wd10m';

    final apiKey =
        'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImY3NDAzZjU3NTZjNTljZmI3NmViMmE3MmE4ZjE4NmE4MDU1NGEwZGM4NjJlNTI1NDgwZTk3NmRlNGE3ODBkNGFmNWRiMmNjNjk2NTk2ZGJlIn0.eyJhdWQiOiIyIiwianRpIjoiZjc0MDNmNTc1NmM1OWNmYjc2ZWIyYTcyYThmMTg2YTgwNTU0YTBkYzg2MmU1MjU0ODBlOTc2ZGU0YTc4MGQ0YWY1ZGIyY2M2OTY1OTZkYmUiLCJpYXQiOjE3MjUyMTIzMDcsIm5iZiI6MTcyNTIxMjMwNywiZXhwIjoxNzU2NzQ4MzA3LCJzdWIiOiIzNDE0Iiwic2NvcGVzIjpbXX0.SR_TtdFSx6iKbhkcmhRwnfVK3xD5Zex6cMR07wKglB4jdjdgS4_d9Imm0eiqsYFz_OttF095wYvCDbOjgpj7G-oBde4SzGhOF1DZW1CYd1lArS1HZzYNz17-JMBzj7P3CKypyzkoOyWAW9FLzldscsaZ3vzCxbyaroS6GRBRNgI1UK1CexekTwKRvFhHgQHjOxWF9aZMmN2cyR8PyNZfRunXSoZt_CgPBAR7hpSTvt7F23fYtTqI4M7UKjl7a11Qpw3szDcTgPjb8Ss-ZD3eX4eLQjGW8DzYj6B72BRoo81hPbkTKxL7DCywE9Y77NoE4DZKf59uXMwecA8AhuBvGtSYRDFJ8y_iUcqNPdDSFO39lVrj-9XKt4BdfQioV30XEGPph0gtg-TvhrUiLJhHyLt35oVt9byD3nSKjlptcVzk492VJnD-lRFWM3r_s1RhsrY9Kw6f27LRZTqq_cj6dy9eMDp4Jzci2an7EhtQeWUqqfAbdy3AuXr9MOePfnlkJrrq6Y3LgHIFMIwHIYn3L4JuVgNojPxXZXuecLOcfGkowiQjBf6QEWVsA6txtwmm6mO2XZbRVWUCL-VxRt2ZDwk8R8wZMR5e-TedWputjwIYM4Ltr9Pb88R_slJmQYqMZKRnzEh6MNNXf-9nDdRRw7VEGmIm4sgHPcXiJcEmz1c'; // ใส่ API Key ของคุณที่นี่

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

  Future<void> fetchHourlyWeatherData(String province) async {
    DateTime now = DateTime.now();
    String date = DateFormat("yyyy-MM-dd").format(now);
    int currentHour = now.hour;

    // สร้าง Array สำหรับเก็บข้อมูลอุณหภูมิรายชั่วโมง
    List<Map<String, String>> hourlyData = [];

    for (int i = 1; i < 7; i++) {
      int hour = (currentHour + i) % 24; // ชั่วโมงในช่วงเวลาถัดไป
      String url =
          'https://data.tmd.go.th/nwpapi/v1/forecast/location/hourly/place?province=$province&date=$date&hour=$hour&duration=1&fields=tc';

      final apiKey =
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImY3NDAzZjU3NTZjNTljZmI3NmViMmE3MmE4ZjE4NmE4MDU1NGEwZGM4NjJlNTI1NDgwZTk3NmRlNGE3ODBkNGFmNWRiMmNjNjk2NTk2ZGJlIn0.eyJhdWQiOiIyIiwianRpIjoiZjc0MDNmNTc1NmM1OWNmYjc2ZWIyYTcyYThmMTg2YTgwNTU0YTBkYzg2MmU1MjU0ODBlOTc2ZGU0YTc4MGQ0YWY1ZGIyY2M2OTY1OTZkYmUiLCJpYXQiOjE3MjUyMTIzMDcsIm5iZiI6MTcyNTIxMjMwNywiZXhwIjoxNzU2NzQ4MzA3LCJzdWIiOiIzNDE0Iiwic2NvcGVzIjpbXX0.SR_TtdFSx6iKbhkcmhRwnfVK3xD5Zex6cMR07wKglB4jdjdgS4_d9Imm0eiqsYFz_OttF095wYvCDbOjgpj7G-oBde4SzGhOF1DZW1CYd1lArS1HZzYNz17-JMBzj7P3CKypyzkoOyWAW9FLzldscsaZ3vzCxbyaroS6GRBRNgI1UK1CexekTwKRvFhHgQHjOxWF9aZMmN2cyR8PyNZfRunXSoZt_CgPBAR7hpSTvt7F23fYtTqI4M7UKjl7a11Qpw3szDcTgPjb8Ss-ZD3eX4eLQjGW8DzYj6B72BRoo81hPbkTKxL7DCywE9Y77NoE4DZKf59uXMwecA8AhuBvGtSYRDFJ8y_iUcqNPdDSFO39lVrj-9XKt4BdfQioV30XEGPph0gtg-TvhrUiLJhHyLt35oVt9byD3nSKjlptcVzk492VJnD-lRFWM3r_s1RhsrY9Kw6f27LRZTqq_cj6dy9eMDp4Jzci2an7EhtQeWUqqfAbdy3AuXr9MOePfnlkJrrq6Y3LgHIFMIwHIYn3L4JuVgNojPxXZXuecLOcfGkowiQjBf6QEWVsA6txtwmm6mO2XZbRVWUCL-VxRt2ZDwk8R8wZMR5e-TedWputjwIYM4Ltr9Pb88R_slJmQYqMZKRnzEh6MNNXf-9nDdRRw7VEGmIm4sgHPcXiJcEmz1c'; // ใส่ API Key ของคุณที่นี่

      try {
        print('Requesting URL: $url'); // Debug log

        final response = await http.get(
          Uri.parse(url),
          headers: {
            'accept': 'application/json',
            'authorization': 'Bearer $apiKey',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Hourly weather data response: $data'); // Debug log

          var forecasts = data['WeatherForecasts']?[0]?['forecasts'];
          if (forecasts != null && forecasts.isNotEmpty) {
            // ดึงค่าอุณหภูมิและแปลงเป็นจำนวนเต็ม
            int temperature = forecasts[0]['data']['tc'].toInt();
            hourlyData.add({
              'hour': '$hour:00',
              'temperature': '$temperature°',
            });
          } else {
            print('No forecast data available for this hour');
          }
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching hourly weather data: $e');
      }
    }

    // ปรับปรุงข้อมูลใน state
    setState(() {
      this.hourlyData = hourlyData;
    });
  }

  Future<void> fetchDailyWeatherData(String province) async {
    DateTime now = DateTime.now();
    String date = DateFormat("yyyy-MM-dd").format(now);
    String url =
        'https://data.tmd.go.th/nwpapi/v1/forecast/location/daily/place?province=$province&date=$date&duration=1&fields=tc_max';

    final apiKey =
        'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImY3NDAzZjU3NTZjNTljZmI3NmViMmE3MmE4ZjE4NmE4MDU1NGEwZGM4NjJlNTI1NDgwZTk3NmRlNGE3ODBkNGFmNWRiMmNjNjk2NTk2ZGJlIn0.eyJhdWQiOiIyIiwianRpIjoiZjc0MDNmNTc1NmM1OWNmYjc2ZWIyYTcyYThmMTg2YTgwNTU0YTBkYzg2MmU1MjU0ODBlOTc2ZGU0YTc4MGQ0YWY1ZGIyY2M2OTY1OTZkYmUiLCJpYXQiOjE3MjUyMTIzMDcsIm5iZiI6MTcyNTIxMjMwNywiZXhwIjoxNzU2NzQ4MzA3LCJzdWIiOiIzNDE0Iiwic2NvcGVzIjpbXX0.SR_TtdFSx6iKbhkcmhRwnfVK3xD5Zex6cMR07wKglB4jdjdgS4_d9Imm0eiqsYFz_OttF095wYvCDbOjgpj7G-oBde4SzGhOF1DZW1CYd1lArS1HZzYNz17-JMBzj7P3CKypyzkoOyWAW9FLzldscsaZ3vzCxbyaroS6GRBRNgI1UK1CexekTwKRvFhHgQHjOxWF9aZMmN2cyR8PyNZfRunXSoZt_CgPBAR7hpSTvt7F23fYtTqI4M7UKjl7a11Qpw3szDcTgPjb8Ss-ZD3eX4eLQjGW8DzYj6B72BRoo81hPbkTKxL7DCywE9Y77NoE4DZKf59uXMwecA8AhuBvGtSYRDFJ8y_iUcqNPdDSFO39lVrj-9XKt4BdfQioV30XEGPph0gtg-TvhrUiLJhHyLt35oVt9byD3nSKjlptcVzk492VJnD-lRFWM3r_s1RhsrY9Kw6f27LRZTqq_cj6dy9eMDp4Jzci2an7EhtQeWUqqfAbdy3AuXr9MOePfnlkJrrq6Y3LgHIFMIwHIYn3L4JuVgNojPxXZXuecLOcfGkowiQjBf6QEWVsA6txtwmm6mO2XZbRVWUCL-VxRt2ZDwk8R8wZMR5e-TedWputjwIYM4Ltr9Pb88R_slJmQYqMZKRnzEh6MNNXf-9nDdRRw7VEGmIm4sgHPcXiJcEmz1c'; // ใส่ API Key ของคุณที่นี่

    try {
      print('Requesting URL: $url'); // Debug log

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Daily weather data response: $data'); // Debug log

        var forecasts = data['WeatherForecasts']?[0]?['forecasts'];
        if (forecasts != null && forecasts.isNotEmpty) {
          int temperature = forecasts[0]['data']['tc_max'].toInt();
          String dayOfWeek =
              DateFormat('EEEE', 'th_TH').format(now); // วันในภาษาไทย
          dailyWeather = '$dayOfWeek: $temperature°';
        } else {
          dailyWeather = 'No daily data available';
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching daily weather data: $e');
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Widget สำหรับแสดงอุณหภูมิหลัก
            GestureDetector(
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
                      weatherData?['temperature']?.toString() != null
                          ? '${weatherData?['temperature'].toStringAsFixed(0)}°C'
                          : 'N/A',
                      style:
                          TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$selectedProvince\nประเทศไทย',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      DateFormat("HH:mm").format(
                          DateTime.now()), // แสดงเวลาปัจจุบันในรูปแบบ HH:mm
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20), // เพิ่มระยะห่างระหว่าง Widget
            // Widget สำหรับแสดงข้อมูลพยากรณ์อากาศรายชั่วโมง
            Container(
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
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount:
                        hourlyData.length, // ใช้ข้อมูลใน Array ที่สร้างไว้
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      childAspectRatio: 1 / 1.5, // ปรับ childAspectRatio
                    ),
                    itemBuilder: (context, index) {
                      String hour = hourlyData[index]['hour']!;
                      String temperature = hourlyData[index]['temperature']!;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(hour, style: TextStyle(fontSize: 15)),
                          SizedBox(height: 2), // เพิ่มการเว้นช่อง
                          Text(temperature,
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // เพิ่มระยะห่างระหว่าง Widget
            // Widget สำหรับแสดงข้อมูลเพิ่มเติม เช่น ความชื้น ความเร็วลม
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
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
                    children: [
                      Text('ความชื้น', style: TextStyle(fontSize: 16)),
                      Text(
                        weatherData?['humidity'] != null
                            ? '${weatherData?['humidity']}%'
                            : 'N/A',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20), // ระยะห่างระหว่างกล่องข้อมูล
                Container(
                  width: 140,
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
                    children: [
                      Text('ความเร็วลม', style: TextStyle(fontSize: 16)),
                      Text(
                        weatherData?['windSpeed'] != null
                            ? '${weatherData?['windSpeed']} m/s'
                            : 'N/A',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Widget สำหรับแสดงข้อมูลพยากรณ์อากาศรายวัน
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
                child: Text(
                  dailyWeather ??
                      'Loading daily data...', // แสดงข้อมูลพยากรณ์รายวัน
                  style: TextStyle(fontSize: 16),
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
                                dailyWeather = null; // รีเซ็ตข้อมูลรายวัน
                              });
                              fetchWeatherDataByProvince(selectedProvince!);
                              fetchHourlyWeatherData(selectedProvince!);
                              fetchDailyWeatherData(
                                  selectedProvince!); // เรียกข้อมูลรายวัน
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
