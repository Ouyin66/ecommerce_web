import 'package:ecommerce_web/api/api_size.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/const.dart';

class AddSizeForm extends StatefulWidget {
  const AddSizeForm({super.key});

  @override
  State<AddSizeForm> createState() => _AddSizeFormState();
}

class _AddSizeFormState extends State<AddSizeForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  void _addSize() async {
    var response = await APISize().Insert(_nameController.text);
    if (response?.size != null || response?.successMessage != null) {
      print(response?.size?.name);
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
        backgroundColor: branchColor,
        elevation: 4.0,
        title: Text(
          "Thêm kích cỡ",
          style: GoogleFonts.barlow(
            color: whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: whiteColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField('Tên kích cỡ', _nameController, (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên kích cỡ';
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
          _addSize();
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
