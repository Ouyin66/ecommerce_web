import 'package:ecommerce_web/config/const.dart';
import 'package:flutter/material.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildBoxCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxCard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildCard(),
        const Spacer(),
        _buildCard(),
        const Spacer(),
        _buildCard(),
      ],
    );
  }

  Widget _buildCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              "Số đơn hàng trong hệ thống",
              style: subhead,
            ),
            Text(
              "10000",
              style: heading2,
            )
          ],
        ),
      ),
    );
  }
}
