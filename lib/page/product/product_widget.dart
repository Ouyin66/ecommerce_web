import 'package:ecommerce_web/api/api_product.dart';
import 'package:ecommerce_web/model/product.dart';
import 'package:ecommerce_web/page/product/add_product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/const.dart';
import '../../main.dart';
import 'detail_product.dart';
import 'package:flutter_avif/flutter_avif.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({super.key});

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> with RouteAware {
  TextEditingController searchController = TextEditingController();

  List<Product> lst = [];
  List<Product> filteredProducts = [];

  bool sortAscending = true;

  void getData() async {
    var response = await APIProduct().GetList();

    if (response != null) {
      setState(() {
        lst = List.from(response);
        filteredProducts = List.from(lst);
      });
    } else {
      print("Lấy danh sách thất bại");
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      MainApp.routeObserver.subscribe(this, route as PageRoute<dynamic>);
    }
    getData();
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Danh sách sản phẩm",
                style: heading2,
              ),
              const SizedBox(height: 10),
              _buildAddButton(),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PaginatedDataTable(
                    headingRowColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.grey.shade200),
                    columns: [
                      DataColumn(label: Text('ID', style: column)),
                      DataColumn(label: Text('genderID', style: column)),
                      DataColumn(label: Text('categoryID', style: column)),
                      DataColumn(label: Text('Tên', style: column)),
                      DataColumn(label: Text('Mô tả', style: column)),
                      DataColumn(label: Text('Giá', style: column)),
                      DataColumn(label: Text('Giá giảm', style: column)),
                      DataColumn(label: Text('Số lượng', style: column)),
                      DataColumn(label: Text('Trạng thái', style: column)),
                      DataColumn(label: Text('Ngày tạo', style: column)),
                    ],
                    source: _ProductDataSource(lst, context),
                    rowsPerPage: 6,
                    sortColumnIndex: 0,
                    columnSpacing: 12.0,
                    horizontalMargin: 12.0,
                    showCheckboxColumn: false,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearching() {
    return TextField(
      controller: searchController,
      decoration: const InputDecoration(
        labelText: 'Tìm kiếm sản phẩm',
        suffixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        _buildForm(context, const AddProductForm());
      },
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          "Thêm sản phẩm",
          style: subhead,
        ),
      ),
    );
  }

  Future<void> _buildForm(BuildContext context, Widget widget) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        Size screenSize = MediaQuery.of(context).size;
        double dialogWidth = screenSize.width * 0.8;
        double dialogHeight = screenSize.height * 0.9;
        return Dialog(
          elevation: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30), // Bo góc của dialog
            child: Container(
              width: dialogWidth,
              height: dialogHeight,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              color: Colors.white,
              child: widget,
            ),
          ),
        );
      },
    );
  }
}

class _ProductDataSource extends DataTableSource {
  final List<Product> products;
  final BuildContext context;
  _ProductDataSource(this.products, this.context);

  @override
  DataRow getRow(int index) {
    final product = products[index];
    DateTime dateTime = DateTime.parse(product.dateCreate!);
    var formattedDate = DateFormat('HH:mm - dd/MM/yyyy').format(dateTime);

    return DataRow(
      cells: [
        DataCell(Text(product.id.toString(), style: row)),
        DataCell(Text(product.genderID.toString(), style: row)),
        DataCell(Text(product.categoryID.toString(), style: row)),
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 200),
            child: Text(
              product.name.toString(),
              style: row,
              softWrap: true,
              // overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 200), // Giới hạn chiều ngang.
            child: Text(
              product.describe.toString(),
              style: row,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(
            NumberFormat('###,###.### đ').format(product.price ?? 0).toString(),
            style: row)),
        DataCell(Text(product.discount.toString(), style: row)),
        DataCell(Text(product.amount.toString(), style: row)),
        DataCell(Text(product.state.toString(), style: row)),
        DataCell(Text(formattedDate, style: row)),
      ],
      onSelectChanged: (isSelected) async {
        if (isSelected != null && isSelected) {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              Size screenSize = MediaQuery.of(context).size;
              double dialogWidth = screenSize.width * 0.8;
              double dialogHeight = screenSize.height * 0.9;
              return Dialog(
                elevation: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30), // Bo góc của dialog
                  child: Container(
                    width: dialogWidth,
                    height: dialogHeight,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 40),
                    color: Colors.white,
                    child: DetailProductWidget(
                      productId: product.id!,
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  int get rowCount => products.length;

  @override
  bool get hasMoreRows => false;

  @override
  bool get isRowCountApproximate => false; // Assuming the row count is exact

  @override
  int get selectedRowCount => 0; // No rows are selected
}
