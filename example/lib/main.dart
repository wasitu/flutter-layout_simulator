import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:layout_simulator_example/first_page.dart';

import 'package:layout_simulator/layout_simulator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool isEnabled = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: FirstPage(
        onToggle: () {
          setState(() {
            isEnabled = !isEnabled;
          });
        },
      ),
      builder: (context, child) {
        if (kDebugMode) {
          return LayoutSimulator(
            enable: isEnabled,
            child: child ?? SizedBox(),
            onChangedThemeMode: (themeMode) {
              setState(() {
                this._themeMode = themeMode;
              });
            },
          );
        } else {
          return child ?? SizedBox();
        }
      },
    );
  }
}
