import 'package:flutter/material.dart';

class FakeAndroidNavBar extends StatelessWidget {
  final double? height;
  final double cornerRadius;

  FakeAndroidNavBar({this.height, this.cornerRadius = 0.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(cornerRadius),
          bottomRight: Radius.circular(cornerRadius),
        ),
      ),
    );
  }
}
