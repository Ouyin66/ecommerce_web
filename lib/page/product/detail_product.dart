import 'package:ecommerce_web/api/api_picture.dart';
import 'package:ecommerce_web/api/api_product.dart';
import 'package:ecommerce_web/api/api_variant.dart';
import 'package:ecommerce_web/model/picture.dart';
import 'package:ecommerce_web/model/product.dart';
import 'package:ecommerce_web/model/variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../api/api_category.dart';
import '../../api/api_gender.dart';
import '../../config/const.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_switch/flutter_switch.dart';
import '../../main.dart';
import '../../model/category.dart';
import '../../model/gender.dart';
import '../picture/picture_widget.dart';
import '../variant/variant_wdiget.dart';

class DetailProductWidget extends StatefulWidget {
  final Product product;
  const DetailProductWidget({super.key, required this.product});

  @override
  State<DetailProductWidget> createState() => _DetailProductWidgetState();
}

class _DetailProductWidgetState extends State<DetailProductWidget>
    with RouteAware {
  Product product = Product();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  // final _stateController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _selectedCategory = 0;
  int _selectedGender = 0;

  List<Category> lstCategory = [];
  List<Gender> lstGender = [];

  bool _isEdit = false;

  void getData() async {
    var responseCate = await APICategory().GetList();
    var responseGen = await APIGender().GetList();
    // var responseVar = await APIVariant().GetVariantByProduct(product.id!);

    responseCate != [] ? lstCategory = List.from(responseCate!) : lstCategory;
    responseGen != [] ? lstGender = List.from(responseGen!) : lstGender;
    setState(() {});
  }

  void getProduct() async {
    var response = await APIProduct().Get(product.id!);
    if (response != null) {
      setState(() {
        product = response;
      });
    }
  }

  Product saveProduct() => Product(
        id: product.id,
        genderID: _selectedGender,
        categoryID: _selectedCategory,
        name: _nameController.text,
        describe: _descriptionController.text,
        price: double.parse(_priceController.text),
        discount: double.parse(_discountController.text),
        state: product.state,
        amount: product.amount,
        dateCreate: product.dateCreate,
      );

  void _updateProduct(Product product) async {
    var response = await APIProduct().Update(product);
    if (response?.product != null || response?.successMessage != null) {
      showToast(context, "Cập nhật thành công thành công");
      getProduct();
      setState(() {
        _isEdit = false;
      });
    } else if (response?.errorMessage != null) {
      showToast(context, response!.errorMessage!, isError: true);
    }
  }

  @override
  void initState() {
    super.initState();
    product = widget.product;
    _selectedCategory = product.categoryID!;
    _selectedGender = product.genderID!;
    _nameController.text = product.name!;
    _descriptionController.text = product.describe!;
    _priceController.text = product.price.toString();
    _discountController.text = product.discount.toString();
    getData();
    getProduct();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      MainApp.routeObserver.subscribe(this, route);
    }
    getData();
    getProduct();
  }

  @override
  void dispose() {
    MainApp.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {}

  @override
  Widget build(BuildContext context) {
    return lstCategory.isEmpty || lstGender.isEmpty
        ? LoadingScreen()
        : Scaffold(
            backgroundColor: whiteColor,
            appBar: AppBar(
              backgroundColor: whiteColor,
              elevation: 4.0,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Chi tiết sản phẩm",
                    style: GoogleFonts.barlow(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  FlutterSwitch(
                    width: 60.0,
                    height: 30.0,
                    value: _isEdit,
                    activeColor: branchColor,
                    inactiveColor: Colors.grey,
                    toggleSize: 25.0,
                    activeIcon: const Icon(Icons.edit, color: branchColor),
                    inactiveIcon: const Icon(Icons.edit, color: greyColor),
                    onToggle: (val) {
                      setState(() {
                        _isEdit = val;
                      });
                    },
                  )
                ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _buildBoxInformation(),
                          ),
                          // const Spacer(),
                          const VerticalDivider(
                            width: 80,
                          ),
                          // const Spacer(),
                          Expanded(
                            flex: 4,
                            child: _buildGalaryProduct(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxHeight: 500), // Hoặc maxHeight tùy ý
                      child: VariantWidget(product: product),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildGalaryProduct() {
    return PictureWidget(product: product);
  }

  Widget _buildBoxInformation() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInformation("Tên sản phẩm:", null, product.name),
          _isEdit
              ? const SizedBox(
                  height: 5,
                )
              : const SizedBox(),
          // ---------- [MÃ & TỒN KHO]
          Row(
            children: [
              Expanded(
                flex: 6,
                child: _buildInformation("Mã sản phẩm:", null,
                    product.id.toString().padLeft(10, '0'),
                    isView: true),
              ),
              const Spacer(),
              Expanded(
                flex: 4,
                child: _buildInformation("Tồn kho:", null, "${product.amount}",
                    isView: true),
              ),
            ],
          ),
          _isEdit
              ? const SizedBox(
                  height: 5,
                )
              : const SizedBox(),
          // ---------- [TRẠNG THÁI & NGÀI TẠO]
          Row(
            children: [
              Expanded(
                flex: 6,
                child: _buildInformation(
                    "Ngày tạo:",
                    null,
                    DateFormat('HH:mm - dd/MM/yyyy')
                        .format(DateTime.parse(product.dateCreate!)),
                    isView: true),
              ),
              const Spacer(),
              Expanded(
                flex: 4,
                child: _buildInformation(
                    "Trạng thái:", null, "${product.state}",
                    isView: true),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          // ---------- [LOẠI SẢN PHẨM & GIỚI TÍNH]
          lstCategory.isNotEmpty && lstGender.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildDropList<Category>(
                        lstCategory,
                        _selectedCategory,
                        (int? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      flex: 4,
                      child: _buildDropList<Gender>(
                        lstGender,
                        _selectedGender,
                        (int? newValue) {
                          setState(() {
                            _selectedGender = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
          const SizedBox(
            height: 5,
          ),

          // ---------- [GIÁ & GIÁ GIẢM]
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: _buildInformation("Giá:", _priceController, null,
                    isPrice: true),
              ),
              const Spacer(),
              Expanded(
                flex: 5,
                child: _buildInformation("Giá giảm:", _discountController, null,
                    isPrice: true),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          _buildInformation("Mô tả", _descriptionController, null, isDes: true),
          const SizedBox(
            height: 10,
          ),
          _isEdit
              ? Align(
                  alignment: Alignment.centerRight,
                  child: _buildButton(context),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildInformation(
      String labelText, TextEditingController? controller, String? value,
      {bool isPrice = false,
      bool isDescription = false,
      bool isView = false,
      bool isDes = false}) {
    return isDes
        ? Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelText,
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  color: blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormField(
                initialValue: controller == null ? value : null,
                maxLines: null,
                readOnly: isView ? isView : !_isEdit,
                minLines: isDescription ? 5 : null,
                controller: controller,
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                keyboardType:
                    isPrice ? TextInputType.number : TextInputType.multiline,
                inputFormatters: isPrice
                    ? [
                        FilteringTextInputFormatter.digitsOnly,
                      ]
                    : [],
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  // labelText: labelText,
                  // labelStyle: GoogleFonts.barlow(
                  //   color: blackColor,
                  //   fontSize: 16,
                  //   fontWeight: FontWeight.bold,
                  // ),
                  border: _isEdit && isView == false
                      ? FocusBorder()
                      : InputBorder.none,
                  focusedBorder:
                      _isEdit && isView == false ? FocusBorder() : null,
                  enabledBorder:
                      _isEdit && isView == false ? EnableBorder() : null,
                  errorBorder:
                      _isEdit && isView == false ? ErrorBorder() : null,
                  focusedErrorBorder:
                      _isEdit && isView == true ? ErrorFocusBorder() : null,
                  hintText: 'Điền thông tin...',
                  hintStyle: GoogleFonts.barlow(
                    fontSize: 16,
                    color: greyColor,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                  errorStyle: error,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập thông tin';
                  }
                  return null;
                },
                onChanged: null,
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                flex: isView ? 4 : 3,
                child: Text(
                  labelText,
                  style: GoogleFonts.barlow(
                    fontSize: 16,
                    color: blackColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Expanded(
                flex: isView ? 7 : 9,
                child: TextFormField(
                  initialValue: controller == null ? value : null,
                  maxLines: null,
                  readOnly: isView ? isView : !_isEdit,
                  minLines: isDescription ? 5 : null,
                  controller: controller,
                  style: GoogleFonts.barlow(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  keyboardType:
                      isPrice ? TextInputType.number : TextInputType.multiline,
                  inputFormatters: isPrice
                      ? [
                          FilteringTextInputFormatter.digitsOnly,
                        ]
                      : [],
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    border: _isEdit && isView == false
                        ? FocusBorder()
                        : InputBorder.none,
                    focusedBorder:
                        _isEdit && isView == false ? FocusBorder() : null,
                    enabledBorder:
                        _isEdit && isView == false ? EnableBorder() : null,
                    errorBorder:
                        _isEdit && isView == false ? ErrorBorder() : null,
                    focusedErrorBorder:
                        _isEdit && isView == true ? ErrorFocusBorder() : null,
                    hintText: 'Điền thông tin...',
                    hintStyle: GoogleFonts.barlow(
                      fontSize: 16,
                      color: greyColor,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                    errorStyle: (error),
                  ),
                  validator: (value) {
                    if (isPrice) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập giá sản phẩm';
                      } else if (double.parse(value) < 0) {
                        return 'Giá không được âm';
                      }
                      return null;
                    } else if (isView) {
                      return null;
                    } else {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập thông tin';
                      }
                      return null;
                    }
                  },
                  onChanged: null,
                ),
              ),
            ],
          );
  }

  Widget _buildDropList<T>(
      List<T> lst, int selectedValue, ValueChanged<int?> onChanged) {
    String name = '';
    if (lst is List<Category>) {
      name = (lst.firstWhere((obj) => (obj as Category).id == selectedValue)
              as Category)
          .name!;
    } else {
      name = (lst.firstWhere((obj) => (obj as Gender).id == selectedValue)
              as Gender)
          .name!;
    }
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
        _isEdit
            ? DropdownButton<int>(
                value: selectedValue,
                onChanged: _isEdit ? onChanged : null,
                style: GoogleFonts.barlow(
                  color: blackColor,
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
              )
            : Text(
                "$selectedValue - $name",
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ],
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
          _updateProduct(obj);
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
}
