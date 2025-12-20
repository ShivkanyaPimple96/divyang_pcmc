import 'package:flutter/material.dart';

class ResponsiveSize {
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _blockSizeHorizontal;
  static late double _blockSizeVertical;

  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double _safeBlockHorizontal;
  static late double _safeBlockVertical;

  void init(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;

    _safeAreaHorizontal = mediaQuery.padding.left + mediaQuery.padding.right;
    _safeAreaVertical = mediaQuery.padding.top + mediaQuery.padding.bottom;
    _safeBlockHorizontal = (_screenWidth - _safeAreaHorizontal) / 100;
    _safeBlockVertical = (_screenHeight - _safeAreaVertical) / 100;
  }

  // Get responsive width
  static double width(double percentage) {
    return _blockSizeHorizontal * percentage;
  }

  // Get responsive height
  static double height(double percentage) {
    return _blockSizeVertical * percentage;
  }

  // Get safe area width
  static double safeWidth(double percentage) {
    return _safeBlockHorizontal * percentage;
  }

  // Get safe area height
  static double safeHeight(double percentage) {
    return _safeBlockVertical * percentage;
  }

  // Get font size based on screen width
  static double fontSize(double size) {
    return _blockSizeHorizontal * size * 0.25;
  }

  // Get icon size
  static double iconSize(double size) {
    return _blockSizeHorizontal * size * 0.25;
  }

  // Get padding
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left != null
          ? width(left)
          : (horizontal != null
              ? width(horizontal)
              : (all != null ? width(all) : 0)),
      top: top != null
          ? height(top)
          : (vertical != null
              ? height(vertical)
              : (all != null ? height(all) : 0)),
      right: right != null
          ? width(right)
          : (horizontal != null
              ? width(horizontal)
              : (all != null ? width(all) : 0)),
      bottom: bottom != null
          ? height(bottom)
          : (vertical != null
              ? height(vertical)
              : (all != null ? height(all) : 0)),
    );
  }

  // Get screen width
  static double get screenWidth => _screenWidth;

  // Get screen height
  static double get screenHeight => _screenHeight;
}

// Extension for easier usage
extension ResponsiveExtension on num {
  double get w => ResponsiveSize.width(toDouble());
  double get h => ResponsiveSize.height(toDouble());
  double get sw => ResponsiveSize.safeWidth(toDouble());
  double get sh => ResponsiveSize.safeHeight(toDouble());
  double get sp => ResponsiveSize.fontSize(toDouble());
}
