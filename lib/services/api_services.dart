import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart'; // To get the mime type of the file

class ApiService {
  static const String baseUrl = 'http://192.168.1.6:8000/api';
  static final storage = FlutterSecureStorage();

  // Login function with email verification check
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      body: jsonEncode({'email': email, 'password': password}),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];
      await storage.write(key: 'token', value: data['access_token']);
      await storage.write(key: 'user_name', value: user['name']);
      await storage.write(key: 'user_role', value: user['role']);

      // Check email verification immediately after successful login
      return await checkEmailVerification(); // Check email verification after login
    } else {
      return false;
    }
  }

// Check email verification function
  static Future<bool> checkEmailVerification() async {
    final token = await storage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/email/verify'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
    );

    print('Response body: ${response.body}'); // Debugging response body
    print('Response status: ${response.statusCode}'); // Debugging status code

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['message'] == "Email already verified.") {
        return true;
      } else if (responseData['message'] ==
          "Email not verified. Please check your inbox.") {
        return false; // Email is not verified
      }
    } else if (response.statusCode == 403) {
      final responseData = jsonDecode(response.body);
      if (responseData['message'] ==
          "Email not verified. Please check your inbox.") {
        print('Email not verified. Please check your inbox.');
        return false; // Email is not verified
      }
    } else {
      print('Failed response status: ${response.statusCode}');
    }

    throw Exception('Unexpected response: ${response.body}');
  }

  // Register function
  static Future<bool> register(
      String name, String email, String password, String? role) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      body: jsonEncode(
          {'name': name, 'email': email, 'password': password, 'role': role}),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'token', value: data['token']);
      return true;
    } else {
      return false;
    }
  }

  // Fungsi kirim ulang email verifikasi
  static Future<bool> resendVerificationEmail() async {
    final token = await storage.read(key: 'token');
    final response = await http.post(
      Uri.parse('$baseUrl/email/verification-notification'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
    );

    return response.statusCode == 200;
  }

  // Fungsi untuk verifikasi email menggunakan ID dan hash dari deep link
  static Future<bool> verifyEmailFromLink(String id, String hash) async {
    final url = Uri.parse('$baseUrl/email/verify-email-mobile/$id/$hash');
    final token = await storage.read(key: 'token');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      return true; // Verifikasi sukses
    } else {
      return false; // Verifikasi gagal
    }
  }

  // API for get Products (Wedding Organizer)
  static Future<List<Map<String, dynamic>>> getProductsForWO() async {
    final token = await storage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse(
          '$baseUrl/images'), // Gantilah dengan endpoint yang sesuai di API Laravel Anda
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception('Failed to load products');
    }
  }

  // New API call to get orders
  static Future<List<Map<String, dynamic>>> getOrders() async {
    final token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/orders'), // API endpoint for orders
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  // Fungsi untuk mengupdate status order
  static Future<bool> updateOrderStatus(int orderId, String status) async {
    final url = Uri.parse('$baseUrl/orders/$orderId/status');
    final token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('No token found');
    }

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        return true; // Status berhasil diperbarui
      } else {
        print('Failed to update status: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  // Fungsi untuk upload image dan data paket ke server
  static Future<Map<String, dynamic>> uploadImage({
    required String produkName,
    required String produkPrice,
    required String description,
    required XFile imageFile,
  }) async {
    final url = Uri.parse('$baseUrl/images');
    final token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('No token found');
    }

    // Siapkan headers
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Siapkan multipart request
    final request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers)
      ..fields['produk_name'] = produkName
      ..fields['produk_price'] = produkPrice
      ..fields['description'] = description
      ..files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

    // Kirim request dan dapatkan response
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to upload image: ${response.statusCode}");
    }
  }

  // Method to update product details along with an image (if any)
  static Future<void> updateProduct(
    product, {
    required int productId,
    required String productName,
    required String productPrice,
    required String description,
    XFile? image,
  }) async {
    final uri = Uri.parse(
        '$baseUrl/images/$productId?_method=PUT'); // Endpoint to update the product
    var request = http.MultipartRequest('POST', uri);
    final token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('No token found');
    }

    // Add the product details to the request
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.fields['produk_name'] = productName;
    request.fields['produk_price'] = productPrice;
    request.fields['description'] = description;

    // If an image file is provided, add it to the request
    if (image != null) {
      final mimeType = lookupMimeType(image.path)?.split('/');
      final mimeTypeMain = mimeType?.first ?? 'application';
      final mimeTypeSub = mimeType?.last ?? 'octet-stream';

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType(mimeTypeMain, mimeTypeSub),
      ));
    }

    try {
      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        print('Product updated successfully');
      } else {
        print('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Failed to update product');
    }
  }

  /// Fungsi untuk menghapus Image berdasarkan ID
  static Future<bool> deleteImage(int imageId) async {
    final url =
        Uri.parse('$baseUrl/api/images/$imageId'); // Sesuaikan endpoint Anda
    final token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('No token found');
    }

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Ganti dengan token Anda
        },
      );

      if (response.statusCode == 204) {
        // Penghapusan berhasil
        return true;
      } else {
        // Gagal menghapus, Anda dapat menangani error di sini
        print('Failed to delete image: ${response.body}');
        return false;
      }
    } catch (e) {
      // Handle error jaringan atau lainnya
      print('Error deleting image: $e');
      return false;
    }
  }

  // Menampilkan profil pengguna
  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch user profile: ${response.body}");
    }
  }

  // Memperbarui profil pengguna dengan konfirmasi password
  Future<Map<String, dynamic>> updateUserProfile({
    required String name,
    required String email,
    String? password,
    String? confirmPassword, // Tambahkan konfirmasi password
  }) async {
    final token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('No token found');
    }

    final requestBody = {
      'name': name,
      'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
      if (confirmPassword != null && confirmPassword.isNotEmpty)
        'password_confirmation': confirmPassword, // Kirim konfirmasi password
    };

    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update user profile: ${response.body}");
    }
  }

  // Menghapus akun pengguna
  Future<Map<String, dynamic>> deleteUserAccount(String password) async {
    final token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to delete user account: ${response.body}");
    }
  }

  // API for get Products (Wedding Organizer)
  static Future<List<Map<String, dynamic>>> getAllProducts() async {
    final token = await storage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse(
          '$baseUrl/order-images'), // Gantilah dengan endpoint yang sesuai di API Laravel Anda
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<Map<String, dynamic>>> getMyOrders() async {
    final token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/my-orders'), // API endpoint for orders
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  static Future<void> createOrder(Map<String, dynamic> data) async {
    final url = '$baseUrl/orders'; // Sesuaikan URL API Anda
    final token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create order');
    }
  }

  // Function to get stored token
  static Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  static Future<String?> getRole() async {
    return await storage.read(key: "user_role");
  }

  // Function to logout and clear the token
  static Future<void> logout() async {
    await storage.delete(key: 'token');
  }
}
