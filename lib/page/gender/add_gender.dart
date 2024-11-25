import 'package:ecommerce_web/api/api_gender.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/const.dart';

class AddGenderForm extends StatefulWidget {
  const AddGenderForm({super.key});

  @override
  State<AddGenderForm> createState() => _AddGenderFormState();
}

class _AddGenderFormState extends State<AddGenderForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  void _addGender() async {
    var response = await APIGender().Insert(_nameController.text);
    if (response?.gender != null || response?.successMessage != null) {
      print(response?.gender?.name);
      showToast(context, "Thêm thành công");
      Navigator.pop(context);
    } else if (response?.errorMessage != null) {
      showToast(context, response!.errorMessage!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: Text(
          "Thêm giới tính",
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
              _buildInputField('Tên giới tính', _nameController, (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên giới tính';
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
          _addGender();
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
