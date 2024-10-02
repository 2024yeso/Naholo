import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // base64 인코딩을 위한 패키지
import 'dart:io'; // 파일 관련
import 'package:http/http.dart' as http; // 서버 요청을 위한 패키지
import 'package:nahollo/api/api.dart';
// 나홀로일지 글 상세보기
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:provider/provider.dart'; // Provider 패키지 임포트
import 'package:nahollo/models/user_model.dart';

class DiaryWriting extends StatefulWidget {
  const DiaryWriting({super.key});

  @override
  _DiaryWritingState createState() => _DiaryWritingState();
}

class _DiaryWritingState extends State<DiaryWriting> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<File> _imageList = []; // 이미지 파일 리스트
  final List<bool> _subjList = [
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ]; // 주제 선택 상태
  final ImagePicker _picker = ImagePicker(); // ImagePicker 객체 생성

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // 선택된 태그 목록을 반환하는 메서드
  List<String> _getSelectedTags() {
    List<String> selectedTags = [];
    List<String> allTags = [
      '# 혼캎',
      '# 혼영',
      '# 혼놀',
      '# 혼밥',
      '# 혼박',
      '# 혼술',
      '# 기타'
    ];

    for (int i = 0; i < _subjList.length; i++) {
      if (_subjList[i]) {
        selectedTags.add(allTags[i]);
      }
    }
    return selectedTags;
  }

  // 이미지 선택 함수
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageList.add(File(pickedFile.path)); // 선택한 이미지를 리스트에 추가
      });
    }
  }

  // 이미지 인코딩 함수
  Future<List<String>> _encodeImagesToBase64() async {
    List<String> base64Images = [];
    for (File image in _imageList) {
      List<int> imageBytes = await image.readAsBytes(); // 이미지 바이트로 변환
      String base64Image = base64Encode(imageBytes); // base64로 인코딩
      base64Images.add(base64Image);
    }
    return base64Images;
  }

// 서버로 데이터 전송 함수
  Future<void> _uploadData() async {
    // Provider를 통해 사용자 정보를 가져옴
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    UserModel? user = userProvider.user;

    if (user == null) {
      // 유저 정보가 없을 경우 처리
      print("유저 정보가 없습니다.");
      return;
    }

    // 사용자 정보 가져오기
    final userId = user.userId;
    final nickname = user.nickName;

    // 제목, 본문 및 이미지 인코딩된 데이터 준비
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();
    List<String> encodedImages = await _encodeImagesToBase64();
    List<String> selectedTags = _getSelectedTags(); // 선택된 태그 목록

    // 선택된 태그들을 Boolean으로 변환하여 서버로 전달
    Map<String, dynamic> tags = {
      '혼캎': selectedTags.contains('# 혼캎'),
      '혼영': selectedTags.contains('# 혼영'),
      '혼놀': selectedTags.contains('# 혼놀'),
      '혼밥': selectedTags.contains('# 혼밥'),
      '혼박': selectedTags.contains('# 혼박'),
      '혼술': selectedTags.contains('# 혼술'),
      '기타': selectedTags.contains('# 기타'),
    };

    // 서버로 보낼 데이터 구성
    Map<String, dynamic> data = {
      'title': title,
      'content': content,
      'images': encodedImages,
      '혼캎': tags['혼캎'],
      '혼영': tags['혼영'],
      '혼놀': tags['혼놀'],
      '혼밥': tags['혼밥'],
      '혼박': tags['혼박'],
      '혼술': tags['혼술'],
      '기타': tags['기타']
    };

    // user_id를 쿼리 파라미터로 포함시킨 URL
    var url = Uri.parse('${Api.baseUrl}/journal/upload/?user_id=$userId');

    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      // 성공적으로 업로드된 경우
      print('업로드 성공');
      Navigator.pop(context); // 업로드 후 이전 화면으로 돌아가기
    } else {
      // 업로드 실패한 경우
      print('업로드 실패: ${response.statusCode}');
      print('서버 응답: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: SizeScaler.scaleSize(context, 25),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.black, size: SizeScaler.scaleSize(context, 10)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            '일지 작성',
            style: TextStyle(
              fontSize: SizeScaler.scaleSize(context, 8),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: SizeScaler.scaleSize(context, 8)),
            child: Center(
              child: GestureDetector(
                onTap: _uploadData, // 작성 버튼 눌렀을 때 서버로 데이터 전송 함수 호출
                child: Text(
                  '작성',
                  style: TextStyle(
                    fontSize: SizeScaler.scaleSize(context, 8),
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(SizeScaler.scaleSize(context, 0.5)),
          child: Container(
            color: const Color(0xFFBABABA), // 구분선 색상
            height: SizeScaler.scaleSize(context, 0.5), // 구분선 두께
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: SizeScaler.scaleSize(context, 11),
                          top: SizeScaler.scaleSize(context, 3),
                          bottom: SizeScaler.scaleSize(context, 3)),
                      child: TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: '제목을 입력하세요.',
                          hintStyle: TextStyle(
                              color: const Color(0xFFABABAB),
                              fontSize: SizeScaler.scaleSize(context, 11),
                              fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    // 제목 입력창 아래의 구분선
                    Container(
                      color: const Color(0xFFBABABA), // 구분선 색상
                      height: SizeScaler.scaleSize(context, 0.5), // 구분선 두께
                    ),
                    // 이미지 추가 버튼
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: SizeScaler.scaleSize(context, 11),
                          horizontal: SizeScaler.scaleSize(context, 11)),
                      child: ElevatedButton.icon(
                        onPressed: _pickImage, // 버튼 클릭 시 이미지 선택 함수 호출
                        icon: const Icon(Icons.add_photo_alternate),
                        label: Text(
                          '사진 추가',
                          style: TextStyle(
                              fontSize: SizeScaler.scaleSize(context, 8)),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: Size(double.infinity,
                              SizeScaler.scaleSize(context, 25)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                SizeScaler.scaleSize(context, 10)),
                          ),
                        ),
                      ),
                    ),
                    // 선택한 이미지 미리보기
                    _imageList.isNotEmpty
                        ? SizedBox(
                            height: SizeScaler.scaleSize(
                                context, 100), // 이미지 미리보기 높이 설정
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal, // 수평 스크롤
                              itemCount: _imageList.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(
                                          SizeScaler.scaleSize(context, 5)),
                                      child: Image.file(
                                        _imageList[index],
                                        fit: BoxFit.cover,
                                        width: SizeScaler.scaleSize(
                                            context, 80), // 이미지 미리보기 너비 설정
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: IconButton(
                                        icon: const Icon(Icons.cancel,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _imageList
                                                .removeAt(index); // 이미지 삭제
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          )
                        : const SizedBox.shrink(),
                    // 주제 선택란
                    Padding(
                      padding: EdgeInsets.all(
                        SizeScaler.scaleSize(context, 11),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '주제를 선택하세요!',
                              style: TextStyle(
                                fontSize: SizeScaler.scaleSize(context, 7),
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: SizeScaler.scaleSize(context, 6)),
                          Wrap(
                            spacing:
                                SizeScaler.scaleSize(context, 3), // 버튼 사이 간격
                            runSpacing:
                                SizeScaler.scaleSize(context, 3), // 줄 간격
                            children: [
                              '# 혼캎',
                              '# 혼영',
                              '# 혼놀',
                              '# 혼밥',
                              '# 혼박',
                              '# 혼술',
                              '# 기타'
                            ].asMap().entries.map((entry) {
                              int index = entry.key;
                              String topic = entry.value;
                              return SizedBox(
                                height: SizeScaler.scaleSize(context, 13),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _subjList[index] = !_subjList[index];
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: _subjList[index]
                                        ? const Color(0xFFD8CBFF)
                                        : Colors.white,
                                    foregroundColor: const Color(0xFF646464),
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(
                                      SizeScaler.scaleSize(context, 33),
                                      SizeScaler.scaleSize(context, 13),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        SizeScaler.scaleSize(context, 6),
                                      ),
                                      side: _subjList[index]
                                          ? BorderSide(
                                              color: const Color(0xFF794FFF),
                                              width: SizeScaler.scaleSize(
                                                  context, 0.3))
                                          : BorderSide(
                                              color: const Color(0xFF646464),
                                              width: SizeScaler.scaleSize(
                                                  context, 0.3),
                                            ),
                                    ),
                                  ),
                                  child: Text(
                                    topic,
                                    style: TextStyle(
                                      fontSize:
                                          SizeScaler.scaleSize(context, 7),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: const Color(0xFFBABABA).withOpacity(0.5), // 구분선 색상
                      height: SizeScaler.scaleSize(context, 0.5), // 구분선 두께
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: SizeScaler.scaleSize(context, 11)),
                      child: TextField(
                        controller: _contentController,
                        maxLines: null, // 제한 없는 줄 수
                        decoration: InputDecoration(
                          hintText: '내용을 입력하세요.',
                          hintStyle: TextStyle(
                              color: const Color(0xFFABABAB),
                              fontSize: SizeScaler.scaleSize(context, 7),
                              fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          /* Container(
            color: const Color(0xFFBABABA),
            height: SizeScaler.scaleSize(context, 0.5),
          ), */
          /*   SizedBox(
            height: SizeScaler.scaleSize(context, 27), // 높이 설정
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: SizeScaler.scaleSize(context, 26),
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.camera_alt,
                        size: SizeScaler.scaleSize(context, 10)), // 카메라 아이콘
                    onPressed: () {
                      _pickImage;
                    },
                  ),
                ),
              ],
            ),
          ), */
        ],
      ),
    );
  }
}
