import 'package:ecommerce_web/api/api_category.dart';
import 'package:ecommerce_web/api/api_gender.dart';
import 'package:ecommerce_web/api/api_product.dart';
import 'package:ecommerce_web/config/const.dart';
import 'package:ecommerce_web/model/category.dart';
import 'package:ecommerce_web/model/gender.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import '../../model/product.dart';

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _selectedCategory = 0;
  int _selectedGender = 0;

  List<Category> lstCategory = [];
  List<Gender> lstGender = [];

  void getData() async {
    var responseCate = await APICategory().GetList();
    var responseGen = await APIGender().GetList();
    if (responseCate != [] && responseGen != []) {
      setState(() {
        lstCategory = List.from(responseCate!);
        lstGender = List.from(responseGen!);
        _selectedCategory = lstCategory.first.id!;
        _selectedGender = lstGender.first.id!;
      });
      print("Lấy dữ liệu thành công");
    }
  }

  Product saveProduct() => Product(
        genderID: _selectedGender,
        categoryID: _selectedCategory,
        name: _nameController.text,
        describe: _descriptionController.text,
        price: double.parse(_priceController.text),
        discount: 0.0,
        state: 0,
        amount: 0,
      );

  void _addProduct(Product product) async {
    var response = await APIProduct().Insert(product);
    if (response?.product != null || response?.successMessage != null) {
      showToast(context, "Thêm thành công");
      Navigator.pop(context);
    } else if (response?.errorMessage != null) {
      showToast(context, response!.errorMessage!, isError: true);
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: branchColor,
        elevation: 4.0,
        title: Text(
          "Thêm sản phẩm",
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
              _buildDropList<Category>(
                lstCategory,
                _selectedCategory,
                (int? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              _buildDropList<Gender>(
                lstGender,
                _selectedGender,
                (int? newValue) {
                  setState(() {
                    _selectedGender = newValue!;
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              _buildInputField(
                'Tên sản phẩm',
                _nameController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên sản phẩm';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              _buildInputField(
                'Mô tả sản phẩm',
                _descriptionController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mô tả sản phẩm';
                  }
                  return null;
                },
                isDescription: true,
              ),
              const SizedBox(
                height: 10,
              ),
              _buildInputField(
                'Giá sản phẩm',
                _priceController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giá sản phẩm';
                  } else if (double.parse(value) <= 0) {
                    return 'Giá không được âm';
                  }
                  return null;
                },
                isPrice: true,
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
          var obj = saveProduct();
          _addProduct(obj);
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

  Widget _buildInputField(String labelText, TextEditingController controller,
      String? Function(String?) errorMess,
      {bool isPrice = false, bool isDescription = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          maxLines: null,
          minLines: isDescription ? 5 : null,
          controller: controller,
          style: const TextStyle(fontSize: 16),
          keyboardType:
              isPrice ? TextInputType.number : TextInputType.multiline,
          inputFormatters: isPrice
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  // LengthLimitingTextInputFormatter(10),
                ]
              : [],
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

  Widget _buildDropList<T>(
      List<T> lst, int selectedValue, ValueChanged<int?> onChanged) {
    return Row(
      children: [
        Text(
          lst is List<Category> ? "Loại sản phẩm" : "Giới tính",
          style: GoogleFonts.barlow(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        DropdownButton<int>(
          value: selectedValue,
          onChanged: onChanged,
          style: GoogleFonts.barlow(
            fontWeight: FontWeight.bold,
          ),
          dropdownColor: whiteColor,
          items: lst.map<DropdownMenuItem<int>>((T item) {
            if (item is Category) {
              return DropdownMenuItem<int>(
                value: item.id,
                child: Text(item.name ?? ''),
              );
            } else if (item is Gender) {
              return DropdownMenuItem<int>(
                value: item.id,
                child: Text(item.name ?? ''),
              );
            }
            return null!;
          }).toList(),
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
