import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pemburu_mantu/services/api_services.dart';
import 'package:pemburu_mantu/widgets/wo_sidebar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Impor google_fonts

class HomeWOPage extends StatefulWidget {
  @override
  _HomeWOPageState createState() => _HomeWOPageState();
}

class _HomeWOPageState extends State<HomeWOPage> {
  // This will trigger the FutureBuilder to reload and show the updated data
  Future<List<Map<String, dynamic>>>? _productsFuture;
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
    loadPreferences();
    _productsFuture =
        ApiService.getProductsForWO(); // Initialize future to load products
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
      drawer: WOSidebar(), // Pastikan Sidebar sudah ditambahkan di sini
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _productsFuture, // Use the state variable
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
                            width: double
                                .infinity, // Menetapkan lebar penuh halaman
                            margin: EdgeInsets.symmetric(
                                vertical: 8), // Margin antara item
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
                                // Gambar Produk
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    "http://192.168.1.6:8000${product['image_path']}" ??
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
                                      // Nama Produk
                                      Text(
                                        product['produk_name'],
                                        style: GoogleFonts.nunito(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      // Harga Produk
                                      Text(
                                        '${selectedCurrency} ${formatCurrency(price) ?? 'No price available'}',
                                        style: GoogleFonts.nunito(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      // Deskripsi Produk
                                      Text(
                                        '${product['description']}',
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      // Row untuk tombol Edit dan Delete
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          // Tombol Edit
                                          ElevatedButton(
                                            onPressed: () {
                                              // Tampilkan dialog untuk mengedit produk
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return EditProductDialog(
                                                    product: product,
                                                    onUpdate: () {
                                                      setState(() {
                                                        _productsFuture = ApiService
                                                            .getProductsForWO(); // Refresh the product list
                                                      });
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors
                                                  .amber[600], // Warna tombol
                                            ),
                                            child: Text(
                                              'Edit',
                                              style: GoogleFonts.nunito(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              width: 10), // Jarak antara tombol
                                          // Tombol Delete
                                          ElevatedButton(
                                            onPressed: () {
                                              _deleteProduct(product[
                                                  'id']); // Panggil fungsi hapus produk
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary:
                                                  Colors.red, // Warna tombol
                                            ),
                                            child: Text(
                                              'Delete',
                                              style: GoogleFonts.nunito(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
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

  void _deleteProduct(int productId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E1E2D),
          title: Text(
            'Confirm Deletion',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete this product?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: Text('Delete'),
              style: ElevatedButton.styleFrom(primary: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteImage(productId);
        setState(() {
          _productsFuture =
              ApiService.getProductsForWO(); // Refresh product list
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete product: $e')),
        );
      }
    }
  }
}

class EditProductDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onUpdate;

  EditProductDialog({required this.product, required this.onUpdate});

  @override
  _EditProductDialogState createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  XFile? _image; // Variabel untuk menyimpan gambar yang dipilih

  final ImagePicker _picker = ImagePicker(); // Untuk memilih gambar

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.product['produk_name']);
    _priceController =
        TextEditingController(text: widget.product['produk_price']);
    _descriptionController =
        TextEditingController(text: widget.product['description']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        // Wrap the content inside a scroll view
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Product',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF1E1E2D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _priceController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Price (in IDR)',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF1E1E2D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                style: TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF1E1E2D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color(0xFF1E1E2D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white),
                  ),
                  child: _image == null
                      ? Center(
                          child: Text('Choose an Image',
                              style: TextStyle(color: Colors.white)))
                      : Image.file(File(_image!.path), fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(primary: Colors.white),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      // Call the update product API here
                      // Pastikan Anda mengirimkan parameter yang tepat saat memanggil updateProduct
                      await ApiService.updateProduct(
                        widget
                            .product, // Kirimkan product agar kita dapat mendapatkan id-nya
                        productId: widget.product['id'],
                        productName: _nameController.text,
                        productPrice: _priceController.text,
                        description: _descriptionController.text,
                        image: _image, // Kirim gambar yang telah dipilih
                      );
                      widget.onUpdate(); // Trigger refresh on the main screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Product updated successfully!'),
                        ),
                      );
                      Navigator.pop(context); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                    child: Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
