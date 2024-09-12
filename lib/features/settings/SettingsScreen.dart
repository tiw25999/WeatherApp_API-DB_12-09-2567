import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/Login.dart'; // Update this import path

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    setState(() {
      _user = FirebaseAuth.instance.currentUser; // รับผู้ใช้ปัจจุบัน
    });
  }

  void _handleLogout() async {
    await FirebaseAuth.instance.signOut(); // ออกจากระบบ
    setState(() {
      _user = null; // รีเซ็ตสถานะผู้ใช้
    });
    print('User has logged out.'); // แสดงข้อความเมื่อทำการ Logout สำเร็จ
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // ไปยังหน้า Settings
            },
          ),
          ListTile(
            leading: Icon(_user == null ? Icons.login : Icons.logout),
            title: Text(_user == null ? 'Login' : 'Logout'),
            onTap: () async {
              if (_user == null) {
                // ใช้ async/await เพื่อรอผลจากการนำทางไปยังหน้า Login
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Login(onLoginSuccess: () {
                            setState(() {
                              _user = FirebaseAuth.instance.currentUser;
                            });
                          })),
                );
                if (result == true) {
                  _checkLoginStatus(); // อัปเดตสถานะผู้ใช้
                }
              } else {
                _handleLogout(); // ถ้าล็อกอินแล้ว ให้ทำการ logout
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.palette),
            title: Text('Theme'),
            onTap: () {
              // ไปยังหน้า Theme
            },
          ),
        ],
      ),
    );
  }
}
