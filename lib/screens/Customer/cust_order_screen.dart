import 'package:flutter/material.dart';
import 'package:pemburu_mantu/services/api_services.dart';
import 'package:pemburu_mantu/widgets/cust_sidebar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustOrderScreen extends StatefulWidget {
  @override
  State<CustOrderScreen> createState() => _CustOrderScreenState();
}

class _CustOrderScreenState extends State<CustOrderScreen> {
  String selectedTimeZone = 'WIB'; // Default timezone
  String selectedCurrency = 'IDR'; // Default currency
  final Map<String, double> exchangeRates = {
    'IDR': 1.0, // 1 IDR
    'USD': 0.000067, // Contoh: 1 IDR = 0.000067 USD
    'JPY': 0.0073, // Contoh: 1 IDR = 0.0073 JPY
    'RM': 0.00031, // Contoh: 1 IDR = 0.00031 RM
    'SGD': 0.00009, // Contoh: 1 IDR = 0.00009 SGD
  };

  @override
  void initState() {
    super.initState();
    loadPreferences(); // Load the saved timezone
  }

  // Load timezone and currency from SharedPreferences
  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTimeZone =
          prefs.getString('time_zone') ?? 'WIB'; // Default timezone
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

  String formatDate(String dateString) {
    try {
      print('Menerima tanggal: $dateString');
      DateTime dateTime = DateTime.parse(dateString);

      // Konversi waktu berdasarkan zona waktu
      switch (selectedTimeZone) {
        case 'WITA':
          dateTime = dateTime.add(Duration(hours: 1)); // WITA = WIB + 1 jam
          break;
        case 'WIT':
          dateTime = dateTime.add(Duration(hours: 2)); // WIT = WIB + 2 jam
          break;
        case 'London':
          dateTime =
              dateTime.subtract(Duration(hours: 7)); // London = WIB - 7 jam
          break;
        default:
          // WIB atau default
          break;
      }

      String formattedDate = DateFormat("dd MMM yyyy, HH:mm:ss", "id_ID")
          .format(dateTime.toLocal());
      print('Tanggal setelah diformat: $formattedDate');
      return formattedDate;
    } catch (e) {
      print('Terjadi kesalahan: $e');
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF151521), // Warna latar belakang utama
      appBar: AppBar(
        title: Text('Customer Orders'),
        backgroundColor: Color(0xFF1A1A2E), // Warna appbar yang gelap
      ),
      drawer: CustSidebar(), // Sidebar khusus customer
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: ApiService.getMyOrders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final orders = snapshot.data!;
                    return Expanded(
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final price = double.tryParse(
                                  order['image']['produk_price'].toString()) ??
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
                                    "http://192.168.1.6:8000${order['image']['image_path']}" ??
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
                                        order['image']['produk_name'] ??
                                            'Product Name',
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
                                      SizedBox(height: 15),
                                      Row(
                                        children: [
                                          Text(
                                            "Name : ",
                                            style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            order['customer_name'] ??
                                                'Customer Name',
                                            style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            "Email : ",
                                            style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            order['customer_email'] ??
                                                'Customer Email',
                                            style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            "Phone : ",
                                            style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            order['customer_phone'] ??
                                                'Customer Phone',
                                            style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            "Alamat : ",
                                            style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            order['alamat'] ??
                                                'Customer Alamat',
                                            style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            "Waktu Order : ",
                                            style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            ('${formatDate(order['created_at'] ?? '')} ${selectedTimeZone}'),
                                            style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            "Status : ",
                                            style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            order['status'] ?? 'pending',
                                            style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
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
                    return Text('No orders available.');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
