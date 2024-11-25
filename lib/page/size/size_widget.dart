import 'package:ecommerce_web/api/api_size.dart';
import 'package:ecommerce_web/model/size.dart';
import 'package:ecommerce_web/page/size/add_size.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/const.dart';
import '../../main.dart';

class SizeWidget extends StatefulWidget {
  const SizeWidget({super.key});

  @override
  State<SizeWidget> createState() => _SizeWidgetState();
}

class _SizeWidgetState extends State<SizeWidget> with RouteAware {
  TextEditingController searchController = TextEditingController();

  List<MySize> lst = [];
  List<MySize> filteredSizes = [];

  bool sortAscending = true;

  void getData() async {
    var response = await APISize().GetList();

    if (response != null) {
      setState(() {
        lst = List.from(response);
        filteredSizes = List.from(lst);
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
                "Danh sách kích cỡ",
                style: heading2,
              ),
              const SizedBox(height: 10),
              _buildAddButton(),
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
                    source: _SizeDataSource(filteredSizes),
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

  Widget _buildAddButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () async {
        await _buildForm(context, const AddSizeForm());
      },
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          "Thêm kích cỡ",
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

class _SizeDataSource extends DataTableSource {
  final List<MySize> sizes;
  _SizeDataSource(this.sizes);

  @override
  DataRow getRow(int index) {
    final size = sizes[index];

    return DataRow(cells: [
      DataCell(Text(size.id.toString(), style: row)),
      DataCell(Text(size.name.toString(), style: row)),
    ]);
  }

  @override
  int get rowCount => sizes.length;

  @override
  bool get hasMoreRows => false;

  @override
  bool get isRowCountApproximate => false; // Assuming the row count is exact

  @override
  int get selectedRowCount => 0; // No rows are selected
}
