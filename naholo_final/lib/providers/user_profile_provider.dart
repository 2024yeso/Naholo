import 'package:flutter/material.dart';
import 'package:nahollo/models/user_profile.dart';
import 'dart:typed_data';
import 'dart:convert';

class UserProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  // 유저 프로필 설정
  void setUserProfile(UserProfile userProfile) {
    _userProfile = userProfile;
    notifyListeners(); // 상태 변경 알림
  }

  // 프로필 이미지 변경
  void updateUserImage(Uint8List? newImage) {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(image: newImage);
      notifyListeners();
    }
  }

  // 닉네임 변경
  void updateNickname(String newNickname) {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(nickname: newNickname);
      notifyListeners();
    }
  }

  // 자기소개 변경
  void updateIntroduce(String newIntroduce) {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(introduce: newIntroduce);
      notifyListeners();
    }
  }

  // 캐릭터 변경
  void updateUserCharacter(String newCharacter) {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(userCharacter: newCharacter);
      notifyListeners();
    }
  }

  // 팔로워/팔로잉 수 변경
  void updateFollowerCount(int newFollowerCount) {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(follower_count: newFollowerCount);
      notifyListeners();
    }
  }

  void updateFollowingCount(int newFollowingCount) {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(following_count: newFollowingCount);
      notifyListeners();
    }
  }

  // 유저 프로필 초기화
  void clearUserProfile() {
    _userProfile = null;
    notifyListeners();
  }
}
