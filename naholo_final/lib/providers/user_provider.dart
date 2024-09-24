import 'package:flutter/material.dart';
import 'package:nahollo/models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners(); // 상태 변경 알림
  }

  // userCharacter만 변경하는 메서드
  void updateUserCharacter(String newCharacter) {
    if (_user != null) {
      _user!.userCharacter = newCharacter; // userCharacter만 변경
      notifyListeners(); // 상태 변경 알림
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
