import 'package:flutter/material.dart';

class SizeScaler {
  static double scaleSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    const double scale = 197;

    return baseSize * (screenWidth / scale);
  }
}
