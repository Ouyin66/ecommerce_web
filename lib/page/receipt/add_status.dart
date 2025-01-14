import 'package:ecommerce_web/api/api_category.dart';
import 'package:ecommerce_web/api/api_gender.dart';
import 'package:ecommerce_web/api/api_product.dart';
import 'package:ecommerce_web/api/api_status.dart';
import 'package:ecommerce_web/config/const.dart';
import 'package:ecommerce_web/model/category.dart';
import 'package:ecommerce_web/model/gender.dart';
import 'package:ecommerce_web/model/order_status_history.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import '../../model/product.dart';

class AddStatusForm extends StatefulWidget {
  final int receiptId;
  const AddStatusForm({super.key, required this.receiptId});

  @override
  State<AddStatusForm> createState() => _AddStatusFormState();
}

class _AddStatusFormState extends State<AddStatusForm> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  int _selectedState = 0;
  int _selectedReceipt = 0;

  final List<Map<String, dynamic>> orderStates = [
    {"id": 0, "name": "Đã hủy"},
    {"id": 1, "name": "Đang xử lý"},
    {"id": 2, "name": "Đang giao"},
    {"id": 3, "name": "Đã giao"},
  ];

  void _addStatus() async {
    var response = await APIStatus()
        .Insert(_selectedReceipt, _selectedState, _notesController.text);
    if (response?.status != null || response?.successMessage != null) {
      showToast(context, "Thêm thành công");
      Navigator.pop(context);
    } else if (response?.errorMessage != null) {
      showToast(context, response!.errorMessage!, isError: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedReceipt = widget.receiptId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: branchColor,
        elevation: 4.0,
        title: Text(
          "Cập nhật trạng thái đơn hàng",
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
              Text(
                "Mã hóa đơn: HD${_selectedReceipt.toString().padLeft(10, '0')}",
                style: GoogleFonts.barlow(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildDropList(),
              const SizedBox(
                height: 10,
              ),
              _buildInputField(
                'Ghi chú',
                _notesController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập ghi chú';
                  }
                  return null;
                },
              ),
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
          _addStatus();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Text(
          "Lưu",
          style: subhead,
        ),
      ),
    );
  }

  Widget _buildInputField(
    String labelText,
    TextEditingController controller,
    String? Function(String?) errorMess,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          maxLines: null,
          minLines: 3,
          controller: controller,
          style: const TextStyle(fontSize: 16),
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: GoogleFonts.barlow(
              fontSize: 16,
              fontWeight: FontWeight.bold,
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

  Widget _buildDropList() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            "Loại trạng thái:",
            style: GoogleFonts.barlow(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 6,
          child: DropdownButton<int>(
            value: _selectedState, // Giá trị trạng thái hiện tại (kiểu int)
            onChanged: (int? newValue) {
              setState(() {
                _selectedState = newValue!; // Cập nhật trạng thái được chọn
              });
            },
            style: GoogleFonts.barlow(
              fontWeight: FontWeight.bold,
            ),
            dropdownColor: Colors.white,
            items: orderStates.map<DropdownMenuItem<int>>((state) {
              return DropdownMenuItem<int>(
                value: state["id"], // Sử dụng id của trạng thái
                child: Text(state["name"] ?? ''), // Hiển thị tên trạng thái
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// RatingBar.builder(
//                             initialRating: 4,
//                             minRating: 1,
//                             direction: Axis.horizontal,
//                             allowHalfRating: true,
//                             itemCount: 5,
//                             itemPadding:
//                                 const EdgeInsets.symmetric(horizontal: 2),
//                             itemBuilder: (context, _) => const Icon(
//                               Icons.star_rounded,
//                               color: starColor,
//                             ),
//                             onRatingUpdate: (rating) => {},
//                           ),