import 'package:ecommerce_web/config/const.dart';
import 'package:ecommerce_web/page/category/category_widget.dart';
import 'package:ecommerce_web/page/color/color_widget.dart';
import 'package:ecommerce_web/page/gender/gender_widget.dart';
import 'package:ecommerce_web/page/home/home_widget.dart';
import 'package:ecommerce_web/page/product/product_widget.dart';
import 'package:ecommerce_web/page/promotion/promotion_widget.dart';
import 'package:ecommerce_web/page/receipt/receipt_widget.dart';
import 'package:ecommerce_web/page/size/size_widget.dart';
import 'package:ecommerce_web/page/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/sharepre.dart';
import '../model/user.dart';
import 'product/add_product.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  User user = User.userEmpty();
  int _selectedIndex = 0;
  bool _isExpanded = false;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeWidget(),
    const ProductWidget(),
    const ReceiptWidget(),
    const UserWidget(),
    const PromotionWidget(),
    const GenderWidget(),
    const CategoryWidget(),
    const ColorWidget(),
    const SizeWidget(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void getDataUser() async {
    user = await getUser();
    if (user != null) {
      print("Tìm thấy user");
    } else {
      print("Không tìm thấy user");
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getDataUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor.withOpacity(0.97),
      body: Row(
        children: [
          NavigationRail(
            extended: _isExpanded,
            backgroundColor: branchColor,
            unselectedIconTheme: const IconThemeData(
              color: whiteColor,
              opacity: 1,
            ),
            unselectedLabelTextStyle: GoogleFonts.barlow(
              fontSize: 16,
              color: whiteColor,
              fontWeight: FontWeight.bold,
            ),
            selectedIconTheme: const IconThemeData(
              color: branchColor,
            ),
            selectedLabelTextStyle: GoogleFonts.barlow(
              fontSize: 16,
              color: whiteColor,
              fontWeight: FontWeight.bold,
            ),
            elevation: 5,
            indicatorColor: whiteColor,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_rounded),
                label: Text("Trang chủ"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_rounded),
                label: Text("Sản phẩm"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_rounded),
                label: Text("Hóa đơn"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_rounded),
                label: Text("Người dùng"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.percent_rounded),
                label: Text("Khuyến mãi"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.transgender_rounded),
                label: Text("Giới tính"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.category_rounded),
                label: Text("Loại sản phẩm"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.color_lens_rounded),
                label: Text("Màu sắc"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.checkroom_rounded),
                label: Text("Kích cỡ"),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              _onItemTapped(index);
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        icon: const Icon(Icons.menu),
                      ),
                      const Spacer(),
                      _buildAvatar(),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: _widgetOptions.elementAt(_selectedIndex),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipOval(
          child: Image.asset(
            urlAvatar,
            fit: BoxFit.cover,
            width: 50,
            height: 50,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        // Text(
        //   user.name ?? '',
        //   style: name,
        // ),
        // const SizedBox(
        //   width: 20,
        // ),
        TextButton(
          onPressed: () {},
          child: Text(
            "Đăng xuất",
            style: logout,
          ),
        ),
      ],
    );
  }
}
