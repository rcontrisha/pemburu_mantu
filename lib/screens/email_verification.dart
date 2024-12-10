import 'package:flutter/material.dart';
import 'package:pemburu_mantu/screens/login.dart';
import 'package:pemburu_mantu/screens/Wedding%20Organizer/wo_home_screen.dart';
import 'package:pemburu_mantu/services/api_services.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

class EmailVerificationPage extends StatefulWidget {
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool isResending = false;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // Listener for deep link
  void _initDeepLinkListener() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(Uri.parse(initialLink));
      }

      _sub = linkStream.listen((String? link) {
        if (link != null) {
          _handleDeepLink(Uri.parse(link));
        }
      }, onError: (err) {
        print('Failed to receive deep link: $err');
      });
    } catch (e) {
      print('Error initializing deep link listener: $e');
    }
  }

  // Function to handle deep link
  void _handleDeepLink(Uri uri) {
    _navigateToLoginPage();
  }

  // Navigate to Login page if verification failed
  void _navigateToLoginPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Function to resend verification email
  void _resendVerificationEmail() async {
    setState(() {
      isResending = true;
    });
    bool success = await ApiService.resendVerificationEmail();
    setState(() {
      isResending = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? "Verification email resent successfully!"
            : "Failed to resend verification email."),
      ),
    );
  }

  // Optional: Logout function to clear session and navigate to LoginPage
  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(
                    'assets/app_icon.png'), // Replace with your image path
              ),
              SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      "Please verify your email by clicking the link sent to your inbox. If you haven't received it, click below to resend.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isResending ? null : _resendVerificationEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isResending
                          ? CircularProgressIndicator(
                              color: Color(0xFF1A1A2E),
                            )
                          : Text(
                              'RESEND VERIFICATION EMAIL',
                              style: TextStyle(color: Color(0xFF1A1A2E)),
                            ),
                    ),
                    TextButton(
                      onPressed: _logout,
                      child: Text(
                        'Log Out',
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
