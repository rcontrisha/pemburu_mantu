import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pemburu_mantu/screens/Customer/cust_home_screen.dart';
import 'package:pemburu_mantu/screens/email_verification.dart';
import 'package:pemburu_mantu/screens/Wedding%20Organizer/wo_home_screen.dart';
import 'package:pemburu_mantu/screens/register.dart';
import 'package:pemburu_mantu/services/api_services.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  static final storage = FlutterSecureStorage();

  void _login() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Panggil API login dan cek verifikasi email
      final isLoggedIn = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

      setState(() {
        isLoading = false;
      });

      if (isLoggedIn) {
        // Ambil role dari secure storage
        final role = await storage.read(
            key: 'user_role'); // Asumsikan fungsi ini sudah ada

        if (role == "Customer") {
          // Jika role adalah Customer
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CustHomeScreen()),
          );
        } else if (role == "Wedding Organizer") {
          // Jika role adalah Wedding Organizer
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeWOPage()),
          );
        } else {
          // Jika role tidak dikenali
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Role not recognized!")),
          );
        }
      } else {
        // Jika email belum diverifikasi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email not verified! Please verify your email."),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmailVerificationPage()),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to login: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF111827),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(
                    'assets/logo.png'), // Replace with your image path
              ),
              SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF111827),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Color(
                                  0xFF374151)), // Border color set to #374151
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Color(0xFF374151)), // Focused border color
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Color(0xFF374151)), // Enabled border color
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF111827),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Color(0xFF374151)), // Focused border color
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Color(0xFF374151)), // Enabled border color
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: false,
                          onChanged: (bool? value) {},
                          activeColor: Colors.blue, // Checked state color
                          checkColor: Colors.white, // Checkmark color
                          fillColor: MaterialStateProperty.resolveWith<Color>(
                              (states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.blue; // Checked state
                            }
                            return Color(0xFF111827); // Unchecked state color
                          }),
                          side: BorderSide(color: Color(0xFF374151), width: 2),
                        ),
                        Text(
                          'Remember me',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(
                                color: Color(0xFF1A1A2E),
                              )
                            : Text(
                                'LOG IN',
                                style: TextStyle(color: Color(0xFF1A1A2E)),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        'Daftar Akun?',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    Text(
                      '|',
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot your password?',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
