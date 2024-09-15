import 'package:flutter/material.dart';

class MediaQueryUtil {
  // 화면 너비 반환
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // 화면 높이 반환
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // 특정 퍼센트의 화면 너비를 반환
  static double getWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  // 특정 퍼센트의 화면 높이를 반환
  static double getHeightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }
}
