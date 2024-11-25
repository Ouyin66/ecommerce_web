import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:ecommerce_web/api/api_color.dart';
import 'package:ecommerce_web/model/color.dart';
import 'package:ecommerce_web/page/color/add_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/const.dart';
import '../../main.dart';

class ColorWidget extends StatefulWidget {
  const ColorWidget({super.key});

  @override
  State<ColorWidget> createState() => _ColorWidgetState();
}

class _ColorWidgetState extends State<ColorWidget> with RouteAware {
  TextEditingController searchController = TextEditingController();

  List<MyColor> lst = [];
  List<MyColor> filteredColors = [];

  bool sortAscending = true;

  void getData() async {
    var response = await APIColor().GetList();

    if (response != null) {
      setState(() {
        lst = List.from(response);
        filteredColors = List.from(lst);
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Danh sách màu sắc",
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
                      DataColumn(label: Text('Hình', style: column)),
                    ],
                    source: _ColorDataSource(filteredColors),
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
        await _buildForm(context, const AddColorForm());
      },
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          "Thêm màu sắc",
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

class _ColorDataSource extends DataTableSource {
  final List<MyColor> colors;
  _ColorDataSource(this.colors);

  @override
  DataRow getRow(int index) {
    final color = colors[index];
    return DataRow(cells: [
      DataCell(Text(color.id.toString(), style: row)),
      DataCell(Text(color.name.toString(), style: row)),
      DataCell(AvifImage.memory(
        color.image!,
        width: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.memory(
            color.image!,
            width: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image),
          );
        },
      )),
    ]);
  }

  @override
  int get rowCount => colors.length;

  @override
  bool get hasMoreRows => false;

  @override
  bool get isRowCountApproximate => false; // Assuming the row count is exact

  @override
  int get selectedRowCount => 0; // No rows are selected
}
