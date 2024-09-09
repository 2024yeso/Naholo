// size_scaler.dart
import 'package:flutter/material.dart';

class SizeScaler {
  static double scaleSize(BuildContext context, double baseSize, [double? maxSize]) {
    final screenWidth = MediaQuery.of(context).size.width;

    const double scale = 197;
    double scaledSize = baseSize * (screenWidth / scale);

    // 최대값이 설정된 경우, 최대값을 넘지 않도록 조정
    if (maxSize != null) {
      scaledSize = scaledSize.clamp(0.0, maxSize);
    }

    return scaledSize;
  }
}
