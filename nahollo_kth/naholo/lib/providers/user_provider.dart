// providers/user_provider.dart

import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _user;

  UserProfile? get user => _user;

  void setUser(UserProfile userProfile) {
    _user = userProfile;
    notifyListeners();
  }
}
