// size_scaler.dart
import 'package:flutter/material.dart';

class SizeScaler {
  static double scaleSize(BuildContext context, double baseSize, [double minSizeScale = 0, double maxSizeScale = 2]) {
    final screenWidth = MediaQuery.of(context).size.width;

    double scale = screenWidth / 197;
    scale = scale.clamp(minSizeScale, maxSizeScale);
    double scaledSize = baseSize * scale;

    return scaledSize;
  }
}
// 화면이 너무 작은 폰까지 고려해서 최소 배율도 설정할지?
