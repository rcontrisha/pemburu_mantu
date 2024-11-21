import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pemburu_mantu/services/api_services.dart';
import 'dart:io';
import 'package:pemburu_mantu/widgets/wo_sidebar.dart';

class WoPostScreen extends StatefulWidget {
  @override
  _WoPostScreenState createState() => _WoPostScreenState();
}

class _WoPostScreenState extends State<WoPostScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Controllers for input fields
  final TextEditingController _produkNameController = TextEditingController();
  final TextEditingController _produkPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProduct() async {
    if (_selectedImage != null) {
      try {
        final response = await ApiService.uploadImage(
          produkName: _produkNameController.text,
          produkPrice: _produkPriceController.text,
          description: _descriptionController.text,
          imageFile: XFile(_selectedImage!.path),
        );

        // Handle the response after a successful upload
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Image uploaded successfully!'),
          backgroundColor: Colors.green,
        ));

        Navigator.pushNamed(context, '/dataWedding');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to upload image: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select an image to upload.'),
        backgroundColor: Colors.orange,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF151521),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        title: Text('Upload Image', style: TextStyle(color: Colors.white)),
      ),
      drawer: WOSidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Center(
                          child: Text(
                            'Silahkan upload gambar dibawah ini\n\nDrag & Drop your files or Browse',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                ),
              ),
              SizedBox(height: 24),

              // Input Fields
              _buildTextField(
                  "Nama Produk", "Nama Produk", _produkNameController),
              _buildTextField(
                  "Harga Produk", "Harga Produk", _produkPriceController),
              _buildTextField("Deskripsi Produk", "Deskripsi Produk",
                  _descriptionController,
                  maxLines: 4),

              SizedBox(height: 24),

              // Upload Button
              ElevatedButton(
                onPressed: _uploadProduct,
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Upload',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String title, String hintText, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFF111827),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white54),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF374151)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF374151)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF374151)),
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
