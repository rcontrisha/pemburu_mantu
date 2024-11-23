import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pemburu_mantu/screens/Customer/cust_home_screen.dart';
import 'package:pemburu_mantu/screens/Customer/cust_order_screen.dart';
import 'package:pemburu_mantu/screens/Wedding%20Organizer/wo_home_screen.dart';
import 'package:pemburu_mantu/screens/Wedding%20Organizer/wo_order_screen.dart';
import 'package:pemburu_mantu/screens/Wedding%20Organizer/wo_post_screen.dart';
import 'package:pemburu_mantu/screens/login.dart';
import 'package:pemburu_mantu/screens/profile_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);  // Inisialisasi locale Indonesia (id_ID)
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
