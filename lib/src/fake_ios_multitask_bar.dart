import 'package:flutter/widgets.dart';

class FakeIOSMultitaskBar extends StatelessWidget {
  final double? width;
  final bool? tablet;
  final Color? color;

  FakeIOSMultitaskBar({this.width, this.tablet, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.0,
      child: Center(
        child: Container(
          width: width,
          height: tablet! ? 5.0 : 4.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
        ),
      ),
    );
  }
}
