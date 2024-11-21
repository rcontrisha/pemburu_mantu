import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pemburu_mantu/services/api_services.dart';

class CustSidebar extends StatefulWidget {
  @override
  _CustSidebarState createState() => _CustSidebarState();
}

class _CustSidebarState extends State<CustSidebar> {
  static final storage = FlutterSecureStorage();
  bool isProfileExpanded = false;
  String userName = 'Loading...'; // Default value until the name is fetched

  @override
  void initState() {
    super.initState();
    loadUserName(); // Call the function to load the username
  }

  // Load the username asynchronously
  Future<void> loadUserName() async {
    String? name = await storage.read(key: 'user_name');
    setState(() {
      userName = name ?? 'User'; // Default to 'User' if name is not found
    });
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage('assets/logo.png'),
                  ),
                ],
              ),
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
              title: 'Pesan Paket Wedding',
              onTap: () => Navigator.pushNamed(context, '/pesanWedding'),
            ),
            SidebarItem(
              icon: Icons.grid_view,
              title: 'Pesananan Saya',
              onTap: () => Navigator.pushNamed(context, '/pesananSaya'),
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
