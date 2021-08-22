import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:layout_simulator/src/device_list.dart';
import 'package:layout_simulator/src/device_specification.dart';

import 'device_spec_list.dart';
import 'fake_android_nav_bar.dart';
import 'fake_ios_multitask_bar.dart';
import 'fake_status_bar.dart';

const double _kSettingsHeight = 72.0;

class LayoutSimulator extends StatefulWidget {
  final Widget child;
  final bool enable;
  final Function(ThemeMode)? onChangedThemeMode;

  /// Creates a new [DeviceSimulator].
  LayoutSimulator({
    required this.child,
    this.onChangedThemeMode,
    this.enable = true,
  });

  _LayoutSimulatorState createState() =>
      _LayoutSimulatorState(onChangedThemeMode: onChangedThemeMode);
}

class _LayoutSimulatorState extends State<LayoutSimulator> {
  final Function(ThemeMode)? onChangedThemeMode;
  _LayoutSimulatorState({this.onChangedThemeMode});

  Key _contentKey = UniqueKey();
  Orientation _simulatedOrientation = Orientation.portrait;
  DeviceSpecification _currentSpec = iosSpecs.first;
  double _screenScale = 0.8;
  double _textScale = 1.0;

  final navigatorKey = GlobalKey<NavigatorState>();
  var _popupMenuOpened = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enable) return widget.child;

    var mq = MediaQuery.of(context);
    var theme = Theme.of(context);
    var spec = _currentSpec;
    // handle orientation
    Size simulatedSize = spec.size ?? Size.zero;
    if (_simulatedOrientation == Orientation.landscape)
      simulatedSize = simulatedSize.flipped;

    double navBarHeight = 0.0;
    if (spec.platform == TargetPlatform.android)
      navBarHeight = spec.navBarHeight ?? 0;

    // handle overflow
    bool overflowWidth = false;
    bool overflowHeight = false;

    if (simulatedSize.width * _screenScale > mq.size.width) {
      overflowWidth = true;
    }

    double settingsHeight = _kSettingsHeight;
    if (simulatedSize.height * _screenScale > mq.size.height - settingsHeight) {
      overflowHeight = true;
    }

    double cornerRadius = spec.cornerRadius;

    EdgeInsets? padding = spec.padding;
    if (_simulatedOrientation == Orientation.landscape &&
        spec.paddingLandscape != null) padding = spec.paddingLandscape;

    var content = MediaQuery(
      key: _contentKey,
      data: mq.copyWith(
        size: Size(simulatedSize.width, simulatedSize.height - navBarHeight),
        padding: padding,
        textScaleFactor: _textScale,
      ),
      child: Theme(
        data: theme.copyWith(
          platform: spec.platform,
        ),
        child: widget.child,
      ),
    );

    Widget clippedContent = ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
      child: Padding(
        padding: EdgeInsets.only(bottom: navBarHeight),
        child: content,
      ),
    );

    Size notchSize = spec.notchSize ?? Size.zero;
    Widget notch;
    if (_simulatedOrientation == Orientation.landscape) {
      notch = Positioned(
        left: 0.0,
        top: (simulatedSize.height - notchSize.width) / 2.0,
        width: notchSize.height,
        height: notchSize.width,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(notchSize.height / 2.0),
              bottomRight: Radius.circular(notchSize.height / 2.0),
            ),
            color: Colors.black,
          ),
        ),
      );
    } else {
      notch = Positioned(
        top: 0.0,
        right: (simulatedSize.width - notchSize.width) / 2.0,
        width: notchSize.width,
        height: notchSize.height,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(notchSize.height / 2.0),
              bottomRight: Radius.circular(notchSize.height / 2.0),
            ),
            color: Colors.black,
          ),
        ),
      );
    }

    Widget fakeStatusBar = Positioned(
      left: 0.0,
      right: 0.0,
      height: padding?.top ?? 0,
      child: FakeStatusBar(height: padding?.top ?? 0),
    );

    Widget fakeMultitaskBar = Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      height: spec.padding?.bottom ?? 0,
      child: FakeIOSMultitaskBar(
        width: simulatedSize.width / 3.0,
        color: Colors.grey,
        tablet: spec.tablet,
      ),
    );

    Widget fakeNavigationBar = Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      height: navBarHeight,
      child: FakeAndroidNavBar(
        height: navBarHeight,
        cornerRadius: cornerRadius,
      ),
    );

    clippedContent = Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            spreadRadius: 16,
            blurRadius: 16,
            offset: Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          clippedContent,
          notch,
          fakeStatusBar,
          if (spec.platform == TargetPlatform.iOS &&
              spec.cornerRadius > 0.0 &&
              mq.size != simulatedSize)
            fakeMultitaskBar,
          if (spec.platform == TargetPlatform.android) fakeNavigationBar,
        ],
      ),
    );

    Widget screen = Material(
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: Alignment(0.0, 0.0),
                    child: OverflowBox(
                      minWidth: simulatedSize.width,
                      minHeight: simulatedSize.height,
                      maxWidth: simulatedSize.width,
                      maxHeight: simulatedSize.height,
                      child: Transform.scale(
                        scale: _screenScale,
                        alignment: Alignment.center,
                        child: Container(
                          width: simulatedSize.width,
                          height: simulatedSize.height,
                          child: clippedContent,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: Colors.black,
                  child: SafeArea(
                    top: false,
                    child: Container(
                      height: _kSettingsHeight,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CupertinoButton(
                              child: Icon(Icons.crop_free, color: Colors.white),
                              onPressed: () {
                                final parentContext =
                                    navigatorKey.currentContext;
                                if (parentContext == null || _popupMenuOpened)
                                  return;
                                setState(() {
                                  _popupMenuOpened = true;
                                });
                                showDialog(
                                  context: parentContext,
                                  barrierColor: Colors.transparent,
                                  builder: (context) {
                                    final size = MediaQuery.of(context).size;
                                    return Opacity(
                                      opacity: 0.90,
                                      child: Dialog(
                                        backgroundColor: Colors.black,
                                        clipBehavior: Clip.antiAlias,
                                        insetPadding: EdgeInsets.symmetric(
                                          horizontal: size.width / 6,
                                          vertical: size.height / 6,
                                        ),
                                        child: Navigator(
                                          onGenerateRoute: (route) =>
                                              MaterialPageRoute(
                                            settings: route,
                                            builder: (context) => DeviceList(
                                              onSelect: (spec) {
                                                setState(() {
                                                  _currentSpec = spec;
                                                });
                                              },
                                              onDone: () {
                                                Navigator.of(parentContext)
                                                    .pop();
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ).whenComplete(() {
                                  setState(() {
                                    _popupMenuOpened = false;
                                  });
                                });
                              },
                            ),
                            Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _currentSpec.name ?? '',
                                    style: TextStyle().copyWith(
                                        color: Colors.white54, fontSize: 10.0),
                                  ),
                                  FittedBox(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          '${(simulatedSize.width * _screenScale).round()}',
                                          style: TextStyle().copyWith(
                                              fontSize: 12,
                                              color: overflowWidth
                                                  ? Colors.orange
                                                  : Colors.white),
                                        ),
                                        Text(
                                          ' • ',
                                          style: TextStyle()
                                              .copyWith(color: Colors.white),
                                        ),
                                        Text(
                                          '${(simulatedSize.height * _screenScale).round()}',
                                          style: TextStyle().copyWith(
                                              fontSize: 12,
                                              color: overflowHeight
                                                  ? Colors.orange
                                                  : Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            VerticalDivider(
                              width: 24.0,
                              thickness: 0.5,
                              color: Colors.grey,
                            ),
                            IconButton(
                              icon: Icon(Icons.crop_portrait),
                              color:
                                  _simulatedOrientation == Orientation.portrait
                                      ? Colors.white
                                      : Colors.white24,
                              onPressed: () {
                                setState(() {
                                  _simulatedOrientation = Orientation.portrait;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.crop_landscape),
                              color:
                                  _simulatedOrientation == Orientation.landscape
                                      ? Colors.white
                                      : Colors.white24,
                              onPressed: () {
                                setState(() {
                                  _simulatedOrientation = Orientation.landscape;
                                });
                              },
                            ),
                            VerticalDivider(
                              width: 24.0,
                              thickness: 0.5,
                              color: Colors.grey,
                            ),
                            if (onChangedThemeMode != null) ...[
                              IconButton(
                                icon: Icon(Icons.light_mode),
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.white24,
                                onPressed: () {
                                  (onChangedThemeMode ??
                                      (_) {})(ThemeMode.light);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.dark_mode),
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.white24,
                                onPressed: () {
                                  (onChangedThemeMode ??
                                      (_) {})(ThemeMode.dark);
                                },
                              ),
                              VerticalDivider(
                                width: 24.0,
                                thickness: 0.5,
                                color: Colors.grey,
                              ),
                            ],
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CupertinoButton(
                                  padding: EdgeInsets.all(4.0),
                                  minSize: 0,
                                  child: Icon(
                                    Icons.linear_scale_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    showSlider(
                                      value: _screenScale,
                                      min: 0.1,
                                      max: 2.0,
                                      onChanged: (value) {
                                        setState(() {
                                          _screenScale = value;
                                        });
                                      },
                                    );
                                  },
                                ),
                                Text(
                                  'screen: × ${_screenScale.toStringAsFixed(1)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      ?.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(width: 16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CupertinoButton(
                                  padding: EdgeInsets.all(4.0),
                                  minSize: 0,
                                  child: Icon(
                                    Icons.linear_scale_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    showSlider(
                                      value: _textScale,
                                      min: 0.1,
                                      max: 4.0,
                                      onChanged: (value) {
                                        setState(() {
                                          _textScale = value;
                                        });
                                      },
                                    );
                                  },
                                ),
                                Text(
                                  'text: × ${_textScale.toStringAsFixed(1)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      ?.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            IgnorePointer(
              ignoring: !_popupMenuOpened,
              child: HeroControllerScope.none(
                child: Navigator(
                  key: navigatorKey,
                  onGenerateRoute: (route) => MaterialPageRoute(
                    settings: route,
                    builder: (context) => Container(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return screen;
  }

  void showSlider({
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    final parentContext = navigatorKey.currentContext;
    if (parentContext == null || _popupMenuOpened) return;
    setState(() {
      _popupMenuOpened = true;
    });
    showDialog(
      context: parentContext,
      barrierColor: Colors.transparent,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        var current = value;
        return Opacity(
          opacity: 0.85,
          child: Dialog(
            backgroundColor: Colors.black,
            clipBehavior: Clip.antiAlias,
            insetPadding: EdgeInsets.only(
              top: size.height * 0.7,
              bottom: size.height * 0.1,
              left: size.width / 5,
              right: size.width / 5,
            ),
            child: Navigator(
              onGenerateRoute: (route) => MaterialPageRoute(
                settings: route,
                builder: (context) => Slider(
                  value: current,
                  divisions: ((max - min) * 10).toInt(),
                  min: min,
                  max: max,
                  onChanged: (double value) {
                    onChanged(value);
                    setState(() {
                      current = value;
                    });
                  },
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        _popupMenuOpened = false;
      });
    });
  }
}
