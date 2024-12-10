import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale Indonesia
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi plugin flutter_local_notifications
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon_1');
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (response) {
      // Callback jika notifikasi ditekan
      debugPrint('Notification payload: ${response.payload}');
    },
  );

  // Menjalankan aplikasi
  runApp(MyApp(flutterLocalNotificationsPlugin));
}

class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  MyApp(this.flutterLocalNotificationsPlugin);

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
