import 'dart:convert';
import 'dart:typed_data';
import 'package:ecommerce_web/api/api_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/const.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_avif/flutter_avif.dart';

class AddColorForm extends StatefulWidget {
  const AddColorForm({super.key});

  @override
  State<AddColorForm> createState() => _AddColorFormState();
}

class _AddColorFormState extends State<AddColorForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Uint8List? _selectedImageBytes;

  void _addColor() async {
    if (_selectedImageBytes != null) {
      final base64Image = base64Encode(_selectedImageBytes!);

      var response = await APIColor().Insert(
        _nameController.text,
        base64Image,
      );
      if (response?.color != null || response?.successMessage != null) {
        print(response?.color?.name);
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
        _selectedImageBytes = fileBytes;
      });
    }
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
        child: Form(
          key: _formKey,
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
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.memory(
                      _selectedImageBytes!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image),
                    );
                  },
                ),
              ],
              const SizedBox(
                height: 20,
              ),
              _buildInputField('Tên màu', _nameController, (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên màu';
                }
                return null;
              }),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: _buildButton(context),
              ),
            ],
          ),
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
        if (_formKey.currentState?.validate() ?? false) {
          _addColor();
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

  Widget _buildInputField(String labelText, TextEditingController controller,
      String? Function(String?) errorMess) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(
              color: blackColor,
              fontSize: 16,
            ),
            border: FocusBorder(),
            focusedBorder: FocusBorder(),
            enabledBorder: EnableBorder(),
            errorBorder: ErrorBorder(),
            focusedErrorBorder: ErrorFocusBorder(),
            // contentPadding:
            //     const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            // filled: true,
            // fillColor: Colors.white,
            errorStyle: error,
          ),
          validator: errorMess,
          onChanged: null,
        ),
      ],
    );
  }
}
