import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:layout_simulator/src/custom_device_builder.dart';
import 'package:layout_simulator/src/device_spec_list.dart';

import 'device_specification.dart';

class DeviceList extends StatefulWidget {
  final Function(DeviceSpecification)? onSelect;
  final Function()? onDone;

  DeviceList({this.onSelect, this.onDone});

  @override
  _DeviceListState createState() =>
      _DeviceListState(onSelect: onSelect, onDone: onDone);
}

class _DeviceListState extends State<DeviceList> {
  final Function(DeviceSpecification)? onSelect;
  final Function()? onDone;

  _DeviceListState({this.onSelect, this.onDone});

  final categories = {
    'iPhone & iPad': Icon(
      IconData(0xe800,
          fontFamily: 'apple_icon', fontPackage: 'layout_simulator'),
      color: Colors.white,
      size: 20.0,
    ),
    'android': Icon(
      Icons.android,
      color: Colors.white,
      size: 20.0,
    ),
    'custom': Icon(
      Icons.devices_other,
      color: Colors.white,
      size: 20.0,
    ),
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = categories.entries;
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
      body: Column(
        children: [
          Divider(color: Colors.grey.withOpacity(0.2)),
          Flexible(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final category = entries.elementAt(index);
                return ListTile(
                  leading: category.value,
                  title: Text(
                    '${category.key}',
                    style: TextStyle().copyWith(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          switch (index) {
                            case 2:
                              return CustomDeviceBuilder(
                                  onDone: onDone, onSelect: onSelect);
                            default:
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
                                        style: TextStyle()
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.grey[900],
                                body: Column(
                                  children: [
                                    Divider(
                                        color: Colors.grey.withOpacity(0.2)),
                                    buildChildContent(index: index),
                                  ],
                                ),
                              );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChildContent({required int index}) {
    switch (index) {
      case 0:
        return buildDevices(specs: iosSpecs);
      case 1:
        return buildDevices(specs: androidSpecs);
      default:
        return SizedBox();
    }
  }

  Widget buildDevices({required List<DeviceSpecification> specs}) {
    return Flexible(
      child: ListView.builder(
        itemCount: specs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              '${specs[index].name}',
              style: TextStyle().copyWith(color: Colors.white),
            ),
            onTap: () {
              (onSelect ?? (spec) {})(specs[index]);
            },
          );
        },
      ),
    );
  }
}
