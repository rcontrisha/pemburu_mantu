import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pemburu_mantu/services/api_services.dart';
import 'package:pemburu_mantu/widgets/cust_sidebar.dart';
import 'package:pemburu_mantu/widgets/wo_sidebar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  static final storage = FlutterSecureStorage();
  final ImagePicker _imagePicker = ImagePicker();

  // Form field controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Password fields
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Foto profil
  String? _profilePhotoUrl;
  File? _selectedPhoto;
  final String baseUrl = 'http://192.168.1.17:8000/storage/';

  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // Fetch profile data from the API
  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _apiService.getUserProfile();
      _nameController.text = profile['data']['name'] ?? '';
      _emailController.text = profile['data']['email'] ?? '';
      _profilePhotoUrl = profile['data']['photo'];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update profile photo
  Future<void> _updateProfilePhoto() async {
    if (_selectedPhoto == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.updateProfilePhoto(
          photo: _selectedPhoto!); // Perbaikan di sini
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated successfully')),
      );
      _fetchProfileData(); // Refresh profile data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update photo: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Pick photo
  Future<void> _pickPhoto() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedPhoto = File(pickedFile.path);
      });
      _updateProfilePhoto();
    }
  }

  // Update profile using the API
  Future<void> _updateProfile() async {
    // Validasi form
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.updateUserProfile(
        name: _nameController.text,
        email: _emailController.text,
        password: _newPasswordController.text.isNotEmpty
            ? _newPasswordController.text
            : null,
        confirmPassword: _confirmPasswordController.text.isNotEmpty
            ? _confirmPasswordController.text
            : null,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Delete account using the API
  Future<void> _deleteAccount() async {
    try {
      await _apiService.deleteUserAccount(_currentPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );
      Navigator.of(context)
          .pushReplacementNamed('/login'); // Redirect after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future:
            storage.read(key: 'user_role'), // Ambil role dari secure storage
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Tampilkan indikator loading jika role belum diambil
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            // Jika terjadi error
            return Scaffold(
              appBar: AppBar(title: const Text("Error")),
              body: Center(child: Text("Error: ${snapshot.error}")),
            );
          }

          final role = snapshot.data;

          return Scaffold(
            backgroundColor: const Color(0xFF151521),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1A1A2E),
              title: const Text('Profile Settings'),
            ),
            drawer: role == "Customer"
                ? CustSidebar() // Sidebar untuk Customer
                : WOSidebar(), // Sidebar untuk Wedding Organizer
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickPhoto,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _selectedPhoto != null
                                ? FileImage(_selectedPhoto!)
                                : (_profilePhotoUrl != null
                                        ? NetworkImage(
                                            '$baseUrl${_profilePhotoUrl}'!)
                                        : AssetImage(
                                            'assets/default_avatar.png'))
                                    as ImageProvider,
                            child: _selectedPhoto == null &&
                                    _profilePhotoUrl == null
                                ? const Icon(Icons.camera_alt, size: 30)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SectionHeader(title: "Profile Information"),
                        ProfileFormField(
                          label: "Name",
                          controller: _nameController,
                        ),
                        const SizedBox(height: 16),
                        ProfileFormField(
                          label: "Email",
                          controller: _emailController,
                        ),
                        const SizedBox(height: 16),
                        SaveButton(onPressed: _updateProfile),
                        const SizedBox(height: 32),
                        const SectionHeader(title: "Update Password"),
                        ProfileFormField(
                          label: "Current Password",
                          controller: _currentPasswordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 16),
                        ProfileFormField(
                          label: "New Password",
                          controller: _newPasswordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 16),
                        ProfileFormField(
                          label: "Confirm Password",
                          controller: _confirmPasswordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 16),
                        SaveButton(onPressed: _updateProfile),
                        const SizedBox(height: 32),
                        const SectionHeader(title: "Delete Account"),
                        const Text(
                          "Once your account is deleted, all of its resources and data will be permanently deleted. Before deleting your account, please download any data or information that you wish to retain.",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        DeleteButton(onPressed: _deleteAccount),
                      ],
                    ),
                  ),
          );
        });
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class ProfileFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;

  const ProfileFormField({
    required this.label,
    required this.controller,
    this.isPassword = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SaveButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5E5CE6),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          "SAVE",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;
  const DeleteButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          "DELETE ACCOUNT",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
