import 'package:flutter/material.dart';

class FirstPage extends StatelessWidget {
  final Function()? onToggle;
  FirstPage({this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return Scaffold(
                                appBar: AppBar(
                                  title: const Text('The 2nd PAGE'),
                                ),
                                body: SizedBox(),
                              );
                            },
                          ),
                        );
                      },
                      child: Text('push'),
                    ),
                    TextButton(
                      onPressed: () {
                        (onToggle ?? () {})();
                      },
                      child: Text('toggle simulator'),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: Colors.amber,
                padding: const EdgeInsets.all(8),
                child: Text(
                  'SAFE AREA CHEKER',
                  textAlign: TextAlign.center,
                  style: TextStyle().copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
