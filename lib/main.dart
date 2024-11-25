import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'page/login.dart';
import 'package:flutter/foundation.dart';
import 'page/mainpage.dart';
import 'page/product/add_product.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginWidget(),
      navigatorObservers: [routeObserver],
    );
  }
}
