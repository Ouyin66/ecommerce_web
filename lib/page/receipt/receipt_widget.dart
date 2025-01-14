import 'package:ecommerce_web/api/api_receipt.dart';
import 'package:ecommerce_web/model/receipt.dart';
import 'package:ecommerce_web/page/receipt/detail_receipt.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/const.dart';
import '../../main.dart';

class ReceiptWidget extends StatefulWidget {
  const ReceiptWidget({super.key});

  @override
  State<ReceiptWidget> createState() => _ReceiptWidgetState();
}

class _ReceiptWidgetState extends State<ReceiptWidget> with RouteAware {
  TextEditingController searchController = TextEditingController();

  List<Receipt> lst = [];
  List<Receipt> filteredReceipts = [];

  bool sortAscending = true;

  void getData() async {
    var response = await APIReceipt().GetList();

    if (response != null) {
      setState(() {
        lst = List.from(response);
        filteredReceipts = List.from(lst);
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
                "Danh sách đơn hàng",
                style: heading2,
              ),
              // const SizedBox(height: 10),
              // _buildAddButton(context),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PaginatedDataTable(
                    headingRowColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.grey.shade200),
                    columns: [
                      DataColumn(label: Text('ID', style: column)),
                      DataColumn(label: Text('userID', style: column)),
                      DataColumn(label: Text('Mã giao dịch', style: column)),
                      DataColumn(label: Text('Tên người đặt', style: column)),
                      DataColumn(label: Text('Địa chỉ', style: column)),
                      DataColumn(label: Text('Số điện thoại', style: column)),
                      DataColumn(label: Text('Giảm giá', style: column)),
                      DataColumn(label: Text('Tổng tiền', style: column)),
                      DataColumn(label: Text('Quan tâm', style: column)),
                      DataColumn(label: Text('Trạng thái', style: column)),
                      DataColumn(label: Text('Ngày tạo', style: column)),
                    ],
                    source: _ReceiptDataSource(lst, context),
                    rowsPerPage: 5,
                    sortColumnIndex: 0,
                    // sortAscending: sortAscending,
                    columnSpacing: 12.0,
                    horizontalMargin: 12.0,
                    showCheckboxColumn: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildAddButton(BuildContext context) {
  //   return ElevatedButton(
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: Colors.green,
  //       foregroundColor: whiteColor,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //     ),
  //     onPressed: () async {
  //       // await _buildForm(context, const AddReceiptForm());
  //     },
  //     child: Padding(
  //       padding: EdgeInsets.all(12),
  //       child: Text(
  //         "Thêm giới tính",
  //         style: subhead,
  //       ),
  //     ),
  //   );
  // }

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

class _ReceiptDataSource extends DataTableSource {
  final List<Receipt> receipts;
  final BuildContext context;
  _ReceiptDataSource(this.receipts, this.context);

  final List<Map<String, dynamic>> orderStates = [
    {"id": 0, "name": "Đã hủy"},
    {"id": 1, "name": "Đang xử lý"},
    {"id": 2, "name": "Đang giao"},
    {"id": 3, "name": "Đã giao"},
  ];

  String getStateName(int? id) {
    final state = orderStates.firstWhere(
      (state) => state['id'] == id,
      orElse: () => {"id": -1, "name": "Không xác định"},
    );
    return state['name'] as String;
  }

  @override
  DataRow getRow(int index) {
    final receipt = receipts[index];

    DateTime dateTime = DateTime.parse(receipt.dateCreate!);
    var formattedDate = DateFormat('HH:mm - dd/MM/yyyy').format(dateTime);
    return DataRow(
      cells: [
        DataCell(Text(receipt.id.toString(), style: row)),
        DataCell(Text(receipt.userId.toString(), style: row)),
        DataCell(Text(receipt.paymentId.toString(), style: row)),
        DataCell(Text(
          receipt.name.toString(),
          style: row,
          softWrap: true,
        )),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              receipt.address.toString(),
              style: row,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(receipt.phone.toString(), style: row)),
        DataCell(Text(
            NumberFormat('###,###.### đ')
                .format(receipt.discount ?? 0)
                .toString(),
            style: row)),
        DataCell(Text(
            NumberFormat('###,###.### đ').format(receipt.total ?? 0).toString(),
            style: row)),
        DataCell(Text(receipt.interest! ? "Có" : "Không", style: row)),
        DataCell(Text(getStateName(receipt.orderStatusHistories?.first.state),
            style: row)),
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
                    child: DetailReceiptWidget(receiptId: receipt.id!),
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
  int get rowCount => receipts.length;

  @override
  bool get hasMoreRows => false;

  @override
  bool get isRowCountApproximate => false; // Assuming the row count is exact

  @override
  int get selectedRowCount => 0; // No rows are selected
}
