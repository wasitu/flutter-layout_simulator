import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'device_specification.dart';

class CustomDeviceBuilder extends StatefulWidget {
  final Function(DeviceSpecification)? onSelect;
  final Function()? onDone;

  CustomDeviceBuilder({this.onSelect, this.onDone});

  @override
  _State createState() => _State(onDone: onDone, onSelect: onSelect);
}

class _State extends State<CustomDeviceBuilder> {
  final Function(DeviceSpecification)? onSelect;
  final Function()? onDone;

  double _width = 320;
  double _height = 568;
  final widthFocusNode = FocusNode();
  final heightFocusNode = FocusNode();
  late final TextEditingController widthEditController;
  late final TextEditingController heightEditController;

  _State({this.onSelect, this.onDone}) {
    widthEditController = TextEditingController(text: _width.toString());
    heightEditController = TextEditingController(text: _height.toString());
  }

  @override
  void initState() {
    widthFocusNode.addListener(() {
      setState(() {});
    });
    heightFocusNode.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    widthFocusNode.dispose();
    heightFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          CupertinoButton(
            onPressed: () {
              (onDone ?? () {})();
            },
            child: Text(
              'DONE',
              style: TextStyle().copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Divider(color: Colors.grey.withOpacity(0.2)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Screen Size:',
                    style: TextStyle().copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: InputDecorationTheme(
                        isDense: true,
                        contentPadding: EdgeInsets.all(12),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: TextField(
                            cursorColor:
                                Theme.of(context).colorScheme.secondary,
                            controller: widthEditController,
                            focusNode: widthFocusNode,
                            style: TextStyle().copyWith(color: Colors.white),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: 'width:',
                              labelStyle: TextStyle().copyWith(
                                color: widthFocusNode.hasFocus
                                    ? Theme.of(context).colorScheme.secondary
                                    : Colors.white,
                              ),
                            ),
                            onChanged: (value) {
                              final parsed = double.tryParse(value);
                              if (parsed == null) {
                                widthEditController.clear();
                                return;
                              }
                              _width = parsed;
                            },
                          ),
                        ),
                        SizedBox(width: 24),
                        Flexible(
                          child: TextField(
                            cursorColor:
                                Theme.of(context).colorScheme.secondary,
                            controller: heightEditController,
                            focusNode: heightFocusNode,
                            style: TextStyle().copyWith(color: Colors.white),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: 'height:',
                              labelStyle: TextStyle().copyWith(
                                color: heightFocusNode.hasFocus
                                    ? Theme.of(context).colorScheme.secondary
                                    : Colors.white,
                              ),
                            ),
                            onChanged: (value) {
                              final parsed = double.tryParse(value);
                              if (parsed == null) {
                                heightEditController.clear();
                                return;
                              }
                              _height = parsed;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 36, maxWidth: 256),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            (onSelect ?? (_) {})(DeviceSpecification(
                              name: 'custom',
                              size: Size(_width, _height),
                            ));
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                          child: Text(
                            'BUILD',
                            style: TextStyle().copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
