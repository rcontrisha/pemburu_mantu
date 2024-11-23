import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pemburu_mantu/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WOSidebar extends StatefulWidget {
  @override
  _WOSidebarState createState() => _WOSidebarState();
}

class _WOSidebarState extends State<WOSidebar> {
  static final storage = FlutterSecureStorage();
  bool isProfileExpanded = false;
  String userName = 'Loading...'; // Default value until the name is fetched
  String selectedTimeZone = 'WIB'; // Default timezone
  String selectedCurrency = 'IDR';

  @override
  void initState() {
    super.initState();
    loadUserName(); // Call the function to load the username
    loadTimeZone(); // Load the saved timezone
    loadCurrency();
  }

  // Load the username asynchronously
  Future<void> loadUserName() async {
    String? name = await storage.read(key: 'user_name');
    setState(() {
      userName = name ?? 'User'; // Default to 'User' if name is not found
    });
  }

  // Load timezone from SharedPreferences
  Future<void> loadTimeZone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTimeZone =
          prefs.getString('time_zone') ?? 'WIB'; // Default timezone
    });
  }

  // Save timezone to SharedPreferences
  Future<void> saveTimeZone(String timeZone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('time_zone', timeZone);
    setState(() {
      selectedTimeZone = timeZone;
    });
  }

  // Load currency from SharedPreferences
  Future<void> loadCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loadedCurrency = prefs.getString('currency');

    setState(() {
      // If loadedCurrency is null, default to 'IDR'
      selectedCurrency =
          ['IDR', 'USD', 'JPY', 'RM', 'SGD'].contains(loadedCurrency)
              ? loadedCurrency! // Use valid loaded value
              : 'IDR'; // Default to 'IDR'
    });

    // Debugging print
    print('Selected currency: $selectedCurrency');
  }

  // Save currency to SharedPreferences
  Future<void> saveCurrency(String currency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    setState(() {
      selectedCurrency = currency; // Update the UI immediately
    });

    // Debugging print
    print('Currency saved: $currency');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFF1E1E2D),
        padding: EdgeInsets.symmetric(vertical: 55),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              crossAxisAlignment: CrossAxisAlignment
                  .start, // Pastikan elemen sejajar di bagian atas
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Pisahkan elemen ke kiri dan kanan
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage('assets/logo.png'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 20), // Top untuk mengatur posisi dropdown
                  child: Column(
                    children: [
                      DropdownButton<String>(
                        dropdownColor: Color(0xFF2A2A3D),
                        value: ['WIB', 'WITA', 'WIT', 'London']
                                .contains(selectedTimeZone)
                            ? selectedTimeZone
                            : 'WIB', // Default jika nilai tidak valid
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        underline: Container(height: 0), // Hilangkan underline
                        items: ['WIB', 'WITA', 'WIT', 'London']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            saveTimeZone(newValue); // Simpan zona waktu
                          }
                        },
                      ),
                      DropdownButton<String>(
                        dropdownColor: Color(0xFF2A2A3D),
                        value: ['IDR', 'USD', 'JPY', 'RM', 'SGD']
                                .contains(selectedCurrency)
                            ? selectedCurrency
                            : 'IDR', // Default jika nilai tidak valid
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        underline: Container(height: 0), // Hilangkan underline
                        items: ['IDR', 'USD', 'JPY', 'RM', 'SGD']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            saveCurrency(newValue); // Simpan mata uang
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Halo $userName!', // Display the user's name here
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Menu Items with Navigation
            SidebarItem(
              icon: Icons.grid_view,
              title: 'Masukan Data Baru',
              onTap: () => Navigator.pushNamed(context, '/dataBaru'),
            ),
            SidebarItem(
              icon: Icons.grid_view,
              title: 'Data Wedding',
              onTap: () => Navigator.pushNamed(context, '/dataWedding'),
            ),
            SidebarItem(
              icon: Icons.grid_view,
              title: 'Pesanan Masuk',
              onTap: () => Navigator.pushNamed(context, '/pesananMasuk'),
            ),
            SizedBox(height: 20),

            // Profile Settings Dropdown with Arrow Icon
            GestureDetector(
              onTap: () {
                setState(() {
                  isProfileExpanded = !isProfileExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 15),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: Color(0xFF7C8DB5)),
                    SizedBox(width: 10),
                    Text(
                      'Profile Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 90),
                    Icon(
                      isProfileExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Color(0xFF808080),
                    ),
                  ],
                ),
              ),
            ),
            // Dropdown items
            if (isProfileExpanded) ...[
              SidebarItem(
                title: 'Profile',
                isSubItem: true,
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
              SidebarItem(
                title: 'Logout',
                isSubItem: true,
                onTap: () {
                  ApiService.logout();
                  Navigator.pushNamed(context, '/');
                  print("Logout action");
                  // Here, you can handle clearing secure storage, logging out etc.
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final bool isSubItem;
  final VoidCallback? onTap; // Add onTap callback to handle navigation

  SidebarItem({
    this.icon,
    required this.title,
    this.isSubItem = false,
    this.onTap, // Constructor for onTap
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: isSubItem ? 75 : 20, bottom: 15),
      child: GestureDetector(
        onTap: onTap, // Handle tap action
        child: Row(
          children: [
            // Only display the icon if it's not a sub-item
            if (!isSubItem && icon != null)
              Icon(icon, color: Color(0xFF7C8DB5)),
            if (!isSubItem) SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
