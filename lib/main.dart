import 'package:flutter/material.dart';
import 'package:pemburu_mantu/screens/Customer/cust_home_screen.dart';
import 'package:pemburu_mantu/screens/Customer/cust_order_screen.dart';
import 'package:pemburu_mantu/screens/Wedding%20Organizer/wo_home_screen.dart';
import 'package:pemburu_mantu/screens/Wedding%20Organizer/wo_order_screen.dart';
import 'package:pemburu_mantu/screens/Wedding%20Organizer/wo_post_screen.dart';
import 'package:pemburu_mantu/screens/login.dart';
import 'package:pemburu_mantu/screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/dataBaru': (context) => WoPostScreen(),
        '/dataWedding': (context) => HomeWOPage(),
        '/pesananMasuk': (context) => WoOrderScreen(),
        '/pesanWedding': (context) => CustHomeScreen(),
        '/pesananSaya': (context) => CustOrderScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
