import 'package:ecommerce_web/api/api_gender.dart';
import 'package:ecommerce_web/page/gender/add_gender.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/const.dart';
import '../../main.dart';
import '../../model/gender.dart';

class GenderWidget extends StatefulWidget {
  const GenderWidget({super.key});

  @override
  State<GenderWidget> createState() => _GenderWidgetState();
}

class _GenderWidgetState extends State<GenderWidget> with RouteAware {
  TextEditingController searchController = TextEditingController();

  List<Gender> lst = [];
  List<Gender> filteredGenders = [];

  bool sortAscending = true;

  void getData() async {
    var response = await APIGender().GetList();

    if (response != null) {
      setState(() {
        lst = List.from(response);
        filteredGenders = List.from(lst);
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
                "Danh sách giới tính",
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
                      DataColumn(label: Text('Giới tính', style: column)),
                    ],
                    source: _GenderDataSource(lst),
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
        await _buildForm(context, const AddGenderForm());
      },
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          "Thêm giới tính",
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

class _GenderDataSource extends DataTableSource {
  final List<Gender> genders;
  _GenderDataSource(this.genders);

  @override
  DataRow getRow(int index) {
    final gender = genders[index];

    return DataRow(cells: [
      DataCell(Text(gender.id.toString(), style: row)),
      DataCell(Text(gender.name.toString(), style: row)),
    ]);
  }

  @override
  int get rowCount => genders.length;

  @override
  bool get hasMoreRows => false;

  @override
  bool get isRowCountApproximate => false; // Assuming the row count is exact

  @override
  int get selectedRowCount => 0; // No rows are selected
}
