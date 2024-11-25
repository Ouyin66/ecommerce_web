import 'package:ecommerce_web/api/api_variant.dart';
import 'package:ecommerce_web/model/product.dart';
import 'package:ecommerce_web/model/variant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/const.dart';
import '../../main.dart';
import 'add_variant.dart';
import 'package:flutter_avif/flutter_avif.dart';

class VariantWidget extends StatefulWidget {
  final Product product;
  const VariantWidget({super.key, required this.product});

  @override
  State<VariantWidget> createState() => _VariantWidgetState();
}

class _VariantWidgetState extends State<VariantWidget> with RouteAware {
  TextEditingController searchController = TextEditingController();

  Product product = Product();
  List<Variant> lst = [];
  List<Variant> filteredVariants = [];

  bool sortAscending = true;

  void getData() async {
    var response = await APIVariant().GetVariantByProduct(product.id!);

    if (response != null) {
      setState(() {
        lst = List.from(response);
        filteredVariants = List.from(lst);
      });
    } else {
      print("Lấy danh sách thất bại");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      product = widget.product;
      getData(); // Đảm bảo gọi sau khi widget đã dựng
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      MainApp.routeObserver.subscribe(this, route);
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Danh sách sản phẩm biến thể",
                style: heading2,
              ),
              const SizedBox(height: 10),
              _buildAddButton(context),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PaginatedDataTable(
                    headingRowColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.grey.shade200),
                    columns: [
                      DataColumn(label: Text('ID', style: column)),
                      DataColumn(label: Text('proudctID', style: column)),
                      DataColumn(label: Text('sizeID', style: column)),
                      DataColumn(label: Text('colorID', style: column)),
                      DataColumn(label: Text('Giá', style: column)),
                      DataColumn(label: Text('Số lượng', style: column)),
                      DataColumn(label: Text('Hình ảnh', style: column)),
                      DataColumn(label: Text('Ngày tạo', style: column)),
                    ],
                    source: _VariantDataSource(lst),
                    rowsPerPage: 5, // Số dòng mỗi trang
                    sortColumnIndex: 0,
                    // sortAscending: sortAscending,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () async {
        await _buildForm(
            context,
            AddVariantForm(
              product: product,
            ));
      },
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          "Thêm sản phẩm biến thể",
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

class _VariantDataSource extends DataTableSource {
  final List<Variant> varaints;
  _VariantDataSource(this.varaints);

  @override
  DataRow getRow(int index) {
    final varaint = varaints[index];
    DateTime dateTime = DateTime.parse(varaint.dateCreate!);
    var formattedDate = DateFormat('HH:mm - dd/MM/yyyy').format(dateTime);
    return DataRow(cells: [
      DataCell(Text(varaint.id.toString(), style: row)),
      DataCell(Text(varaint.productID.toString(), style: row)),
      DataCell(Text(varaint.sizeID.toString(), style: row)),
      DataCell(Text(varaint.colorID.toString(), style: row)),
      DataCell(Text(
          NumberFormat('###,###.### đ').format(varaint.price ?? 0).toString(),
          style: row)),
      DataCell(Text(varaint.quantity.toString(), style: row)),
      DataCell(AvifImage.memory(
        varaint.picture!,
        width: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.memory(
            varaint.picture!,
            width: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image),
          );
        },
      )),
      DataCell(Text(formattedDate, style: row)),
    ]);
  }

  @override
  int get rowCount => varaints.length;

  @override
  bool get hasMoreRows => false;

  @override
  bool get isRowCountApproximate => false; // Assuming the row count is exact

  @override
  int get selectedRowCount => 0; // No rows are selected
}
