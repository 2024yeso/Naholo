import 'package:flutter/material.dart';

class SaveProvider with ChangeNotifier {
  // 장소의 저장 상태를 관리할 Map
  Map<String, bool> savedPlaces = {};

  // 저장 상태를 토글하는 함수
  void toggleSave(String placeId, bool isSaved) {
    savedPlaces[placeId] = isSaved;
    notifyListeners(); // 상태가 변경되었음을 알림
  }

  // 특정 장소의 저장 상태를 반환하는 함수
  bool isSaved(String placeId) {
    return savedPlaces[placeId] ?? false; // 저장된 상태가 없으면 false 반환
  }

  // 서버로부터 저장 상태를 받아오는 함수
  void setSavedPlaces(Map<String, bool> places) {
    savedPlaces = places;
    notifyListeners();
  }
}
