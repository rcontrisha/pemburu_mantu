import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:pemburu_mantu/services/api_services.dart';
import 'package:pemburu_mantu/widgets/cust_sidebar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustHomeScreen extends StatefulWidget {
  @override
  _CustHomeScreenState createState() => _CustHomeScreenState();
}

class _CustHomeScreenState extends State<CustHomeScreen> {
  Future<List<Map<String, dynamic>>>? _productsFuture;
  String selectedCurrency = 'IDR'; // Default currency
  final Map<String, double> exchangeRates = {
    'IDR': 1.0, // 1 IDR
    'USD': 0.000067, // Contoh: 1 IDR = 0.000067 USD
    'JPY': 0.0073, // Contoh: 1 IDR = 0.0073 JPY
    'RM': 0.00031, // Contoh: 1 IDR = 0.00031 RM
    'SGD': 0.00009, // Contoh: 1 IDR = 0.00009 SGD
  };

  // Initialize flutterLocalNotificationsPlugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    loadPreferences();
    initializeNotifications();
    createNotificationChannel();
    _productsFuture =
        ApiService.getAllProducts(); // Initialize future to load products
  }

  Future<void> initializeNotifications() async {
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
  }

  // Load timezone and currency from SharedPreferences
  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCurrency =
          prefs.getString('currency') ?? 'IDR'; // Default currency
    });
  }

  void updateCurrency(String currency) {
    setState(() {
      selectedCurrency = currency;
    });
  }

  double convertCurrency(double amount) {
    return (amount * exchangeRates[selectedCurrency]!).toDouble();
  }

  String formatCurrency(double amount) {
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 2,
    );
    return currencyFormat.format(convertCurrency(amount));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF151521),
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Color(0xFF1A1A2E),
      ),
      drawer: CustSidebar(), // Pastikan Sidebar sudah ditambahkan di sini
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final products = snapshot.data!;
                    return Expanded(
                      child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final price = double.tryParse(
                                  product['produk_price'].toString()) ??
                              0.0;
                          return Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFF1E1E2D),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white12,
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    "http://192.168.1.17:8000${product['image_path']}" ??
                                        'https://via.placeholder.com/150',
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['produk_name'],
                                        style: GoogleFonts.nunito(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '${selectedCurrency} ${formatCurrency(price) ?? 'No price available'}',
                                        style: GoogleFonts.nunito(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '${product['description']}',
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return OrderDialog(
                                                  product: product,
                                                  flutterLocalNotificationsPlugin:
                                                      flutterLocalNotificationsPlugin, // Pass it here
                                                );
                                              },
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.green,
                                          ),
                                          child: Text(
                                            'Order',
                                            style: GoogleFonts.nunito(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return Text('No products available.');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'order_channel_id', // ID unik channel
      'Order Notifications', // Nama channel
      description: 'Notifikasi terkait pesanan',
      importance: Importance.high,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.high,
      priority: Priority.high,
    );

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}

class OrderDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  OrderDialog({
    required this.product,
    required this.flutterLocalNotificationsPlugin,
  });

  @override
  _OrderDialogState createState() => _OrderDialogState();
}

class _OrderDialogState extends State<OrderDialog> {
  final _formKey = GlobalKey<FormState>();

  String customerName = '';
  String customerEmail = '';
  String customerPhone = '';
  String alamat = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF1E1E2D),
      title: Text(
        'Order ${widget.product['produk_name']}',
        style: GoogleFonts.nunito(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF2E2E3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  customerName = value!;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Customer Email',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF2E2E3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) {
                  customerEmail = value!;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Customer Phone',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF2E2E3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  customerPhone = value!;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF2E2E3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                onSaved: (value) {
                  alamat = value!;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              // Kirim data order ke API
              ApiService.createOrder({
                'customer_name': customerName,
                'customer_email': customerEmail,
                'customer_phone': customerPhone,
                'alamat': alamat,
                'image_id': widget.product['id'], // Kirim image_id
              }).then((response) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order created successfully!')),
                );
                Navigator.of(context).pop();
                _showNotification();
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to create order: $error')),
                );
              });
            }
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.green,
          ),
          child: Text('Order Now'),
        ),
      ],
    );
  }

  // Fungsi untuk menampilkan notifikasi lokal
  void _showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'order_channel_id', // ID unik untuk saluran
      'Order Notifications', // Nama saluran
      channelDescription: 'Notifikasi untuk pesanan.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await widget.flutterLocalNotificationsPlugin.show(
        1, // ID notifikasi
        'Pesanan Berhasil!',
        'Pesanan kamu telah berhasil dibuat. Silakan menunggu konfirmasi.',
        notificationDetails,
      );
    } catch (e) {
      print('Error saat menampilkan notifikasi: $e');
    }
  }
}
