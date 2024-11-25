import 'package:ecommerce_web/api/api_category.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/const.dart';
import '../../main.dart';
import '../../model/category.dart';
import 'add_category.dart';

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({super.key});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> with RouteAware {
  TextEditingController searchController = TextEditingController();

  List<Category> lst = [];
  List<Category> filteredCategories = [];

  bool sortAscending = true;

  void getData() async {
    var response = await APICategory().GetList();

    if (response != null) {
      setState(() {
        lst = List.from(response);
        filteredCategories = List.from(lst);
      });
    } else {
      print("Lấy danh sách thất bại");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData(); // Đảm bảo gọi sau khi widget đã dựng
    });
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Danh sách loại sản phẩm",
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
                      DataColumn(label: Text('Tên màu', style: column)),
                    ],
                    source: _CategoryDataSource(lst),
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
        await _buildForm(context, const AddCategoryForm());
      },
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          "Thêm loại sản phẩm",
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
        double dialogWidth = screenSize.width * 0.4;
        double dialogHeight = screenSize.height * 0.4;
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

class _CategoryDataSource extends DataTableSource {
  final List<Category> categories;
  _CategoryDataSource(this.categories);

  @override
  DataRow getRow(int index) {
    final category = categories[index];

    return DataRow(cells: [
      DataCell(Text(category.id.toString(), style: row)),
      DataCell(Text(category.name.toString(), style: row)),
    ]);
  }

  @override
  int get rowCount => categories.length;

  @override
  bool get hasMoreRows => false;

  @override
  bool get isRowCountApproximate => false; // Assuming the row count is exact

  @override
  int get selectedRowCount => 0; // No rows are selected
}
