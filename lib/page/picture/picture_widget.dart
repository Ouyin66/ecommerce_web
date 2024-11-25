import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../api/api_picture.dart';
import '../../config/const.dart';
import '../../main.dart';
import '../../model/picture.dart';
import '../../model/product.dart';
import 'add_picture.dart';
import 'package:flutter_avif/flutter_avif.dart';

class PictureWidget extends StatefulWidget {
  final Product product;
  const PictureWidget({super.key, required this.product});

  @override
  State<PictureWidget> createState() => _PictureWidgetState();
}

class _PictureWidgetState extends State<PictureWidget> with RouteAware {
  Product product = Product();
  List<Picture> lstPicture = [];

  void getData() async {
    var responsePic = await APIPicture().getPicturesByProduct(product.id!);

    if (responsePic != null && responsePic.isNotEmpty) {
      lstPicture = List.from(responsePic);
    } else {
      lstPicture = [];
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    product = widget.product;
    getData();
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
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Danh mục hình ảnh",
              style: subhead,
            ),
            const SizedBox(
              height: 10,
            ),
            // Kiểm tra lstPicture, nếu trống vẫn hiển thị nút Add
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 80,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Không cuộn cho GridView bên trong SingleChildScrollView
              itemCount: lstPicture.isEmpty
                  ? 1
                  : lstPicture.length +
                      1, // Nếu lstPicture trống, chỉ có 1 item (nút Add)
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Hiển thị nút Add đầu tiên
                  return _buildAddButton(context);
                } else if (lstPicture.isNotEmpty) {
                  // Nếu danh sách không rỗng, hiển thị hình ảnh trong lstPicture
                  final item =
                      lstPicture[index - 1]; // Trừ 1 vì đã thêm 1 cho nút "Add"

                  return InkWell(
                    onTap: () {
                      // Logic cho tap vào item
                    },
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AvifImage.memory(
                          item.image!,
                          width: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.memory(
                              item.image!,
                              width: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image),
                            );
                          },
                        )),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        // Logic để thêm hình ảnh hoặc thực hiện hành động khác
        await _buildForm(
            context,
            AddPictureForm(
              product: product,
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 30),
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
