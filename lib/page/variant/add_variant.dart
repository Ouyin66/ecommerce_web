import 'dart:convert';
import 'dart:typed_data';
import 'package:ecommerce_web/api/api_color.dart';
import 'package:ecommerce_web/api/api_size.dart';
import 'package:ecommerce_web/model/color.dart';
import 'package:ecommerce_web/model/size.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ecommerce_web/api/api_gender.dart';
import 'package:ecommerce_web/api/api_variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/const.dart';
import '../../model/product.dart';
import 'package:flutter_avif/flutter_avif.dart';

class AddVariantForm extends StatefulWidget {
  final Product product;
  const AddVariantForm({super.key, required this.product});

  @override
  State<AddVariantForm> createState() => _AddVariantFormState();
}

class _AddVariantFormState extends State<AddVariantForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  Uint8List? _selectedImageBytes;

  int _selectedProduct = 0;
  int _selectedColor = 0;
  int _selectedSize = 0;

  List<MyColor> lstColor = [];
  List<MySize> lstSize = [];

  void getData() async {
    var responseColor = await APIColor().GetList();
    var responseSize = await APISize().GetList();
    if (responseColor != [] && responseSize != []) {
      setState(() {
        lstColor = List.from(responseColor!);
        lstSize = List.from(responseSize!);
        _selectedColor = lstColor.first.id!;
        _selectedSize = lstSize.first.id!;
      });
      print("Lấy dữ liệu thành công");
    }
  }

  void _addVaraint() async {
    if (_selectedImageBytes != null) {
      final base64Image = base64Encode(_selectedImageBytes!);
      var response = await APIVariant().Insert(
        _selectedProduct,
        _selectedColor,
        _selectedSize,
        base64Image,
        int.parse(_quantityController.text),
      );
      if (response?.variant != null || response?.successMessage != null) {
        print(response?.variant?.id);
        showToast(context, "Thêm thành công");
        // Navigator.pop(context);
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
    _selectedProduct = widget.product.id!;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return lstColor.isEmpty || lstSize == []
        ? LoadingScreen()
        : Scaffold(
            backgroundColor: whiteColor,
            appBar: AppBar(
              backgroundColor: whiteColor,
              title: Text(
                "Thêm sản phẩm biến",
                style: GoogleFonts.barlow(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
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
                      Text(
                        "Mã sản phẩm: $_selectedProduct - ${widget.product.name ?? ''}",
                        style: GoogleFonts.barlow(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Chọn màu: $_selectedColor - ${lstColor.firstWhere((c) => c.id == _selectedColor).name ?? ''}",
                        style: GoogleFonts.barlow(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      lstColor.isNotEmpty
                          ? buildSelectionGrid<MyColor>(
                              lst: lstColor,
                              isColorGrid: true,
                              selectedId: _selectedColor,
                              onSelected: (id) {
                                setState(() {
                                  _selectedColor = id;
                                });
                              },
                            )
                          : const SizedBox(),
                      const SizedBox(height: 16),
                      Text(
                        "Chọn kích cỡ: $_selectedSize - ${lstSize.firstWhere((s) => s.id == _selectedSize).name ?? ''}",
                        style: GoogleFonts.barlow(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      lstSize.isNotEmpty
                          ? buildSelectionGrid<MySize>(
                              lst: lstSize,
                              isColorGrid: false,
                              selectedId: _selectedSize,
                              onSelected: (id) {
                                setState(() {
                                  _selectedSize = id;
                                });
                              },
                            )
                          : const SizedBox(),
                      const SizedBox(height: 16),
                      _buildInputField('Số lượng', _quantityController),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildButton(context),
                      ),
                    ],
                  ),
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
          _addVaraint();
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

  Widget _buildInputField(String labelText, TextEditingController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 16),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            // LengthLimitingTextInputFormatter(10),
          ],
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập số lượng';
            } else if (double.parse(value) < 0) {
              return 'Số lượng không được âm';
            }
            return null;
          },
          onChanged: null,
        ),
      ],
    );
  }

  Widget buildSelectionGrid<T>({
    required List<T> lst,
    required bool isColorGrid,
    required int selectedId,
    required Function(int) onSelected,
  }) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 80, // Kích thước tối đa của từng item trong lưới
        crossAxisSpacing: 8, // Khoảng cách giữa các cột
        mainAxisSpacing: 8, // Khoảng cách giữa các hàng
        childAspectRatio: lst is List<MyColor> ? 1 : 2,
      ),
      itemCount: lst.length,
      shrinkWrap: true, // Đảm bảo GridView không chiếm toàn bộ không gian
      physics:
          const NeverScrollableScrollPhysics(), // Không scroll bên trong Grid
      itemBuilder: (context, index) {
        final item = lst[index];

        final isSelected = isColorGrid
            ? (item as MyColor).id == selectedId
            : (item as MySize).id == selectedId;

        return GestureDetector(
          onTap: () {
            int? id = isColorGrid ? (item as MyColor).id : (item as MySize).id;
            onSelected(id!);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4), // Tạo khoảng cách bên trong
            child: Center(
              child: isColorGrid
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AvifImage.memory(
                        (item as MyColor).image!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.memory(
                            (item as MyColor).image!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image),
                          );
                        },
                      ),
                    )
                  : Text(
                      (item as MySize).name ?? '',
                      style: GoogleFonts.barlow(
                        color: isSelected ? Colors.green : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
            ),
          ),
        );
      },
    );
  }
}
