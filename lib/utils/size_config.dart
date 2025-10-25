import 'package:flutter/material.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth;
  static late double blockHeight;

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;

    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;
  }

  // Responsive width
  static double wp(double percent, {double? max}) {
    final value = blockWidth * percent;
    return max != null && value > max ? max : value;
  }

  // Responsive height
  static double hp(double percent, {double? max}) {
    final value = blockHeight * percent;
    return max != null && value > max ? max : value;
  }

  // Responsive font
  static double font(double scale, {double? max, double? min}) {
    // Use average of width and height percentages for balanced scaling
    final base = (screenWidth + screenHeight) / 2 / 100;
    final value = base * scale;
    if (min != null && value < min) return min;
    if (max != null && value > max) return max;
    return value;
  }
}
