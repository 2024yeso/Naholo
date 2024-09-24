// lib/screens/profile_edit_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemUiOverlayStyle 사용을 위한 임포트
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/sizescaler.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  File? _profileImage; // 프로필 이미지 파일
  TextEditingController? _nickname; // 닉네임
  TextEditingController? _myself; // 자기소개

  //저장 버튼 함수
  //미구현
  Future<void> _saveButton() async {}

  // 이미지 선택 함수
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // 선택된 이미지를 파일로 저장
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '프로필 관리',
          style: TextStyle(
            color: Colors.black,
            fontSize: SizeScaler.scaleSize(context, 8),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xff843ff9),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeScaler.scaleSize(context, 10),
                vertical: SizeScaler.scaleSize(context, 15),
              ),
              child: TextField(
                controller: _nickname,
                decoration: InputDecoration(
                  labelText: "닉네임",
                  labelStyle: const TextStyle(color: Color(0xff4b0066)),
                  floatingLabelAlignment: FloatingLabelAlignment.start,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: "한글,영문,숫자 2-15 자로 작성해 주세요",
                  hintStyle: TextStyle(
                    color: const Color(0xff843ff9),
                    fontSize: SizeScaler.scaleSize(context, 6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(
                      color: Color(0xff843ff9),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5), // 활성 상태의 테두리 모양
                    borderSide: const BorderSide(
                      color: Color(0xff843ff9), // 활성 상태의 테두리 색상
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeScaler.scaleSize(context, 10),
                vertical: SizeScaler.scaleSize(context, 5),
              ),
              child: TextField(
                controller: _myself,
                maxLines: 4, //상자 크기 설정
                decoration: InputDecoration(
                  alignLabelWithHint: true, // 힌트 텍스트를 상단에 맞춤
                  // 세로 패딩을 늘려서 높이 조절,
                  hintText: "자기소개를 입력해 주세요",

                  hintStyle: TextStyle(
                    color: const Color(0xff843ff9),
                    fontSize: SizeScaler.scaleSize(context, 6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(
                      color: Color(0xff843ff9),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5), // 활성 상태의 테두리 모양
                    borderSide: const BorderSide(
                      color: Color(0xff843ff9), // 활성 상태의 테두리 색상
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: SizeScaler.scaleSize(context, 50),
            ),
            GestureDetector(
              onTap: _saveButton,
              child: Container(
                alignment: Alignment.center,
                width: SizeScaler.scaleSize(context, 180),
                height: SizeScaler.scaleSize(context, 35),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  "저장하기",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
