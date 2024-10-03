import 'dart:convert'; // Base64 인코딩을 위해 추가
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // HTTP 요청을 위해 추가
import 'package:nahollo/models/user_profile.dart';
import 'package:nahollo/providers/user_profile_provider.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/api/api.dart';
import 'package:provider/provider.dart';

class ProfileEditPage extends StatefulWidget {
  Uint8List? image;
  ProfileEditPage({super.key, this.image});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  File? _profileImage; // 프로필 이미지 파일
  final TextEditingController _nickname = TextEditingController(); // 닉네임
  final TextEditingController _myself = TextEditingController(); // 자기소개
  final bool _isLoading = true;
  String? _nicknameError; // 닉네임 에러 메시지

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

  Widget buildProfileImage(Uint8List? image, File? profileImage) {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey[300],
      backgroundImage: getImageProvider(image, profileImage),
      child: profileImage == null && (image == null || image.isEmpty)
          ? const Icon(
              Icons.person,
              size: 80,
              color: Colors.white,
            )
          : null,
    );
  }

  ImageProvider? getImageProvider(Uint8List? image, File? profileImage) {
    if (profileImage != null) {
      return FileImage(profileImage); // 프로필 이미지가 있을 경우
    } else if (image != null && image.isNotEmpty) {
      return MemoryImage(image); // Uint8List 타입의 이미지가 있을 경우
    } else {
      return null; // 둘 다 없으면 null 반환 (기본 아이콘 표시)
    }
  }

  // 이미지를 Base64로 인코딩
  Future<String?> _convertImageToBase64(File? imageFile) async {
    if (imageFile == null) return null;
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  // 닉네임 길이 유효성 검사
  bool _validateNickname() {
    String nickname = _nickname.text.trim();
    if (nickname.isEmpty || nickname.length < 2 || nickname.length > 15) {
      setState(() {
        _nicknameError = '닉네임은 2자에서 15자 사이여야 합니다.';
      });
      return false;
    } else {
      setState(() {
        _nicknameError = null;
      });
      return true;
    }
  }

  // 저장 버튼 클릭 시 서버로 데이터 전송
  Future<void> _saveButton() async {
    if (!_validateNickname()) return; // 닉네임 검사를 통과하지 못하면 중단

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String userId = userProvider.user?.userId ?? "정보 없음"; // 실제 사용자 ID로 변경

    // 이미지 파일을 Base64로 인코딩
    String? encodedImage = await _convertImageToBase64(_profileImage);

    // 서버로 보낼 데이터
    Map<String, dynamic> userData = {
      'NICKNAME': _nickname.text,
      'INTRODUCE': _myself.text,
      'IMAGE': encodedImage,
    };

    // 서버로 HTTP PUT 요청
    try {
      final response = await http.put(
        Uri.parse('${Api.baseUrl}/update_user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData), // 데이터를 JSON으로 변환하여 전송
      );

      if (response.statusCode == 200) {
        // 성공적으로 업데이트되었음을 알림
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 성공적으로 업데이트되었습니다.')),
        );
        print("프로필 수정 완료, Navigator.pop 호출 직전"); // 로그 추가
        Navigator.pop(context, true); // 수정 성공 후 true 값을 반환하며 화면 닫기
      } else {
        // 오류 발생 시 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 업데이트 실패: ${response.body}')),
        );
      }
    } catch (e) {
      print('프로필 업데이트 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버 요청 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final userProfile = userProfileProvider.userProfile;
    final image = userProfile!.image;

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    buildProfileImage(image, _profileImage),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "닉네임",
                      style: TextStyle(
                        color: const Color(0xff4b0066),
                        fontWeight: FontWeight.bold,
                        fontSize: SizeScaler.scaleSize(context, 8),
                      ),
                    ),
                    SizedBox(height: SizeScaler.scaleSize(context, 3)),
                    TextField(
                      controller: _nickname,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(15), // 최대 15자까지 입력 가능
                      ],
                      decoration: InputDecoration(
                        hintText: "한글,영문,숫자 2-15 자로 작성해 주세요",
                        errorText: _nicknameError, // 에러 메시지 표시
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
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Color(0xff843ff9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeScaler.scaleSize(context, 10),
                  vertical: SizeScaler.scaleSize(context, 5),
                ),
                child: TextField(
                  controller: _myself,
                  maxLines: 4,
                  decoration: InputDecoration(
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
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                        color: Color(0xff843ff9),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: SizeScaler.scaleSize(context, 70)),
              GestureDetector(
                onTap: () {
                  _saveButton();
                },
                child: Container(
                  alignment: Alignment.center,
                  width: SizeScaler.scaleSize(context, 180),
                  height: SizeScaler.scaleSize(context, 35),
                  decoration: BoxDecoration(
                    color: const Color(0xff494949),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    "저장하기",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
