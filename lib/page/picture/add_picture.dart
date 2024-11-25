import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:ecommerce_web/api/api_color.dart';
import 'package:ecommerce_web/api/api_picture.dart';
import 'package:ecommerce_web/model/product.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/const.dart';
import 'package:file_picker/file_picker.dart';

class AddPictureForm extends StatefulWidget {
  final Product product;
  const AddPictureForm({super.key, required this.product});

  @override
  State<AddPictureForm> createState() => _AddPictureFormState();
}

class _AddPictureFormState extends State<AddPictureForm> {
  Product product = Product();
  Uint8List? _selectedImageBytes;
  int _selectedProduct = 0;

  void _addPicture() async {
    if (_selectedImageBytes != null) {
      final base64Image = base64Encode(_selectedImageBytes!);

      var response = await APIPicture().Insert(
        _selectedProduct,
        base64Image,
      );
      if (response?.picture != null || response?.successMessage != null) {
        showToast(context, "Thêm thành công");
        Navigator.pop(context);
      } else if (response?.errorMessage != null) {
        showToast(context, response!.errorMessage!, isError: true);
      }
    } else {
      showToast(context, "Hãy thêm hình ảnh vào", isError: true);
    }
  }

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;

      setState(() {
        _selectedImageBytes = fileBytes; // Hiển thị ảnh tạm thời
      });
    }
  }

  @override
  void initState() {
    super.initState();
    product = widget.product;
    _selectedProduct = product.id!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: Text(
          "Thêm màu sắc",
          style: GoogleFonts.barlow(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildButtonImage(),
            if (_selectedImageBytes != null) ...[
              const SizedBox(height: 10),
              Text(
                "Ảnh đã chọn:",
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 5),
              AvifImage.memory(
                _selectedImageBytes!,
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.memory(
                    _selectedImageBytes!,
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image),
                  );
                },
              )
            ],
            const SizedBox(
              height: 20,
            ),
            Text(
              "Mã sản phẩm: $_selectedProduct - ${product.name}",
              style: GoogleFonts.barlow(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: _buildButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonImage() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: greyColor,
        foregroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: pickImage,
      child: Padding(
        padding: EdgeInsets.all(6),
        child: Text(
          "Chọn ảnh",
          style: subhead,
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        if (_selectedImageBytes != null) {
          _addPicture();
        }
      },
      child: Padding(
        padding: EdgeInsets.all(6),
        child: Text(
          "Lưu",
          style: subhead,
        ),
      ),
    );
  }
}
