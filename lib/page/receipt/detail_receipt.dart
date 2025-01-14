import 'dart:math';

import 'package:ecommerce_web/api/api_receipt.dart';
import 'package:ecommerce_web/api/api_variant.dart';
import 'package:ecommerce_web/model/receipt.dart';
import 'package:ecommerce_web/model/receipt_variant.dart';
import 'package:ecommerce_web/model/variant.dart';
import 'package:ecommerce_web/page/receipt/add_status.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/api_status.dart';
import '../../config/const.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../model/order_status_history.dart';
import '../variant/variant_widget.dart';
import 'package:flutter_avif/flutter_avif.dart';

class DetailReceiptWidget extends StatefulWidget {
  final int receiptId;
  const DetailReceiptWidget({super.key, required this.receiptId});

  @override
  State<DetailReceiptWidget> createState() => _DetailReceiptWidgetState();
}

class _DetailReceiptWidgetState extends State<DetailReceiptWidget>
    with RouteAware {
  Receipt receipt = Receipt(receiptVariants: []);
  bool _isLoading = true;
  int mainState = -1;

  List<OrderStatusHistory> listStatus = [];
  // int _sortColumnIndex = 4; // Chỉ số cột 'Ngày tạo'
  // bool _sortAscending = false; // Sắp xếp giảm dần ban đầu

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

  Future<void> getData() async {
    var responsePro = await APIReceipt().Get(widget.receiptId);
    if (responsePro != null) {
      receipt = responsePro;
      for (var item in receipt.receiptVariants) {
        item.variant = await APIVariant().Get(item.variantId!);
      }
    }

    var responseStatus = await APIStatus().getStatusByReceipt(widget.receiptId);
    if (responseStatus != null) {
      setState(() {
        listStatus = List.from(responseStatus);
      });
    } else {
      print("Lấy danh sách thất bại");
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    await getData();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      MainApp.routeObserver.subscribe(this, route);
    }
    _initializeData();
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
    return _isLoading
        ? LoadingScreen()
        : Scaffold(
            backgroundColor: whiteColor,
            appBar: AppBar(
              backgroundColor: branchColor,
              elevation: 4.0,
              title: Text(
                "Chi tiết đơn hàng",
                style: GoogleFonts.barlow(
                  color: whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: const IconThemeData(color: whiteColor),
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
                            child: _buildBoxInfo(),
                          ),
                          // const Spacer(),
                          const VerticalDivider(
                            width: 60,
                          ),
                          // const Spacer(),
                          Expanded(
                            flex: 4,
                            child: _buildListItem(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxHeight: 400), // Hoặc maxHeight tùy ý
                      child: _buildBoxStatus(),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildBoxInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildInformation("Mã giao dịch:", receipt.paymentId ?? ''),
        const SizedBox(
          height: 10,
        ),
        _buildMergeInfo(
          _buildInformation(
            "Mã hóa đơn:",
            "HD${receipt.id.toString().padLeft(10, '0')}",
          ),
          _buildInformation(
            "Trạng thái:",
            getStateName(receipt.orderStatusHistories?.first.state ?? -1),
          ),
          flexLeft: 6,
          flexRight: 4,
        ),
        const SizedBox(
          height: 10,
        ),
        _buildMergeInfo(
          _buildInformation(
            "Ngày tạo:",
            DateFormat('HH:mm - dd/MM/yyyy')
                .format(DateTime.parse(receipt.dateCreate ?? '')),
          ),
          _buildInformation("Quan tâm:", receipt.interest! ? "Có" : "Không"),
          flexLeft: 6,
          flexRight: 4,
        ),
        const SizedBox(
          height: 5,
        ),
        _buildMergeInfo(
          _buildInformation("Tên người đặt:", receipt.name ?? ''),
          _buildInformation(
            "Số điện thoại:",
            receipt.phone ?? '',
            flexLeft: 5,
            flexRight: 5,
          ),
          flexLeft: 6,
          flexRight: 4,
        ),
        const SizedBox(
          height: 10,
        ),
        _buildMergeInfo(
          _buildInformation("Giảm giá:",
              NumberFormat('###,###.### đ').format(receipt.discount ?? 0)),
          _buildInformation("Tổng tiền:",
              NumberFormat('###,###.### đ').format(receipt.total ?? 0)),
        ),
        const SizedBox(
          height: 10,
        ),
        _buildInformation("Địa chỉ giao hàng:", receipt.address ?? ''),
        const SizedBox(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildButtonState(context),
            const SizedBox(
              width: 20,
            ),
            _buildButtonState(context, isCancel: true),
          ],
        ),
      ],
    );
  }

  Widget _buildMergeInfo(Widget widgetLeft, Widget widgetRight,
      {int flexLeft = 5, int flexRight = 5}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: flexLeft,
          child: widgetLeft,
        ),
        const Spacer(),
        Expanded(
          flex: flexRight,
          child: widgetRight,
        ),
      ],
    );
  }

  Widget _buildInformation(String label, String value,
      {int flexLeft = 4, int flexRight = 7}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: flexLeft,
          child: Text(
            label,
            style: GoogleFonts.barlow(
              fontSize: 16,
              color: blackColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        const Spacer(),
        Expanded(
          flex: flexRight,
          child: Text(
            value,
            style: GoogleFonts.barlow(
              fontSize: 16,
              color: blackColor,
              fontWeight: FontWeight.w500,
            ),
            softWrap: true,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildListItem() {
    return SizedBox(
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Danh sách sản phẩm",
            style: subhead,
          ),
          const SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            child: Column(children: [
              ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 5),
                // scrollDirection: Axis.horizontal,
                itemCount: receipt.receiptVariants.length,
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemBuilder: (context, index) {
                  var item = receipt.receiptVariants[index];
                  return _buildItem(index + 1, item, context);
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(int index, ReceiptVariant item, BuildContext context) {
    var product = item.variant?.product;
    var variant = item.variant;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                index.toString(),
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  color: blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Text.rich(
                TextSpan(
                  text: product?.name ?? '',
                  style: GoogleFonts.barlow(
                    fontSize: 14,
                    color: blackColor,
                    fontWeight: FontWeight.w500,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          ' (${variant?.color?.name ?? ''}, ${variant?.size?.name ?? ''})',
                      style: GoogleFonts.barlow(
                        fontSize: 14,
                        color: blackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                softWrap: true,
                maxLines: 2,
              ),
            ),
            const Spacer(),
            Expanded(
              flex: 3,
              child: Text(
                NumberFormat('###,###.### đ').format(item.price ?? 0),
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  color: blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "x${item.quantity.toString()}",
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  color: blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Divider(
          height: 5,
          color: greyColor.withOpacity(0.6),
          // endIndent: 5,
          // indent: 5,
        ),
      ],
    );
  }

  Widget _buildBoxStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Bảng trạng thái đơn hàng",
          style: GoogleFonts.barlow(
            fontSize: 24,
            color: blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        PaginatedDataTable(
          headingRowColor:
              WidgetStateProperty.resolveWith((states) => Colors.grey.shade200),
          columns: [
            DataColumn(label: Text('ID', style: column)),
            DataColumn(label: Text('receiptId', style: column)),
            DataColumn(label: Text('Trạng thái', style: column)),
            DataColumn(label: Text('Ghi chú', style: column)),
            DataColumn(
              label: Text('Ngày tạo', style: column),
            ),
          ],
          source: _StatusDataSource(listStatus),
          rowsPerPage: 5, // Số dòng mỗi trang
          sortColumnIndex: 0,
          // sortAscending: _sortAscending,
        ),
      ],
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

  Widget _buildButtonState(BuildContext context, {bool isCancel = false}) {
    return isCancel
        ? OutlinedButton(
            style: OutlinedButton.styleFrom(
              overlayColor: branchColor,
              foregroundColor: branchColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(color: branchColor),
            ),
            onPressed: () {
              showDeleteDialog(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "Hủy đơn hàng",
                style: subhead,
              ),
            ),
          )
        : ElevatedButton(
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
                AddStatusForm(receiptId: receipt.id!),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "Cập nhật trạng thái",
                style: subhead,
              ),
            ),
          );
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: whiteColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          title: Text(
            "Bạn có chắc muốn hủy đơn hàng này?",
            style: GoogleFonts.barlow(
              fontSize: 24,
              color: blackColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: blackColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Hủy",
                style: subhead,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: branchColor,
                foregroundColor: whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                var response = await APIStatus().Cancel(receipt.id!);
                if (response?.status == null) {
                  showToast(context, "Hủy đơn hàng thành công");
                  Navigator.of(context).pop();
                }
                setState(() {});
              },
              child: Text("Xác nhận", style: subhead),
            ),
          ],
        );
      },
    );
  }
}

class _StatusDataSource extends DataTableSource {
  final List<OrderStatusHistory> lstStatus;
  _StatusDataSource(this.lstStatus);

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
    final status = lstStatus[index];
    DateTime dateTime = DateTime.parse(status.timestamp!);
    var formattedDate = DateFormat('HH:mm:ss - dd/MM/yyyy').format(dateTime);

    return DataRow(cells: [
      DataCell(Text(status.id.toString(), style: row)),
      DataCell(Text(status.receiptId.toString(), style: row)),
      DataCell(Text(getStateName(status.state), style: row)),
      DataCell(Text(status.notes.toString(), style: row)),
      DataCell(Text(formattedDate, style: row)),
    ]);
  }

  @override
  int get rowCount => lstStatus.length;

  @override
  bool get hasMoreRows => false;

  @override
  bool get isRowCountApproximate => false; // Assuming the row count is exact

  @override
  int get selectedRowCount => 0; // No rows are selected
}
