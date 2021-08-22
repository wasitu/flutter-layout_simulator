import 'package:flutter/material.dart';

class FakeStatusBar extends StatelessWidget {
  final double height;

  FakeStatusBar({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
    );
  }
}
