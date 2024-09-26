// diary_writing.dart
import 'package:flutter/material.dart';
import 'diary_text.dart'; // 나홀로일지 글 상세보기
import 'package:flutter_application_1/sizeScaler.dart'; // 크기 조절

class DiaryWriting extends StatefulWidget {
  @override
  _DiaryWritingState createState() => _DiaryWritingState();
}

class _DiaryWritingState extends State<DiaryWriting> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // subjList 상태 관리
  List<bool> _subjList = [false, false, false, false, false, false, false];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 페이지 배경색을 하얀색으로 설정
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
                onTap: () {
                  // 작성 버튼 눌렀을 때의 동작
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryText(
                        postTitle: _titleController.text,
                        postContent: _contentController.text,
                        author: '유저의 이름 가져오기',
                        authorID: '유저의 ID 가져오기',
                        createdAt: DateTime.now(), // 현재 시간을 작성 시간으로 설정
                        subjList: _subjList,
                      ),
                    ),
                  );
                },
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
      body: SingleChildScrollView(
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
                        fontSize: SizeScaler.scaleSize(context, 5),
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: SizeScaler.scaleSize(context, 8)),
                  Wrap(
                    spacing: SizeScaler.scaleSize(context, 5), // 버튼 사이 간격
                    runSpacing: SizeScaler.scaleSize(context, 5), // 줄 간격
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
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // subjList의 인덱스에 해당하는 값을 반전시킴
                            _subjList[index] = !_subjList[index];
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _subjList[index]
                              ? const Color(0xFFD8CBFF) // 선택된 경우 연보라색
                              : Colors.white, // 선택되지 않은 경우 흰색
                          foregroundColor:
                              const Color(0xFF646464), // 선택되지 않은 경우 회색 텍스트
                          padding: EdgeInsets.zero, // 내부 패딩 제거
                          minimumSize: Size(
                            SizeScaler.scaleSize(context, 40), // 버튼 크기
                            SizeScaler.scaleSize(context, 18),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              SizeScaler.scaleSize(context, 33), // 둥글기 정도
                            ),
                            side: _subjList[index]
                                ? BorderSide(
                                    color: const Color(0xFF794FFF), // 윤곽선 색상
                                    width: SizeScaler.scaleSize(
                                        context, 0.3)) // 윤곽선 두께
                                : BorderSide(
                                    color: const Color(0xFF646464), // 윤곽선 색상
                                    width: SizeScaler.scaleSize(
                                        context, 0.3), // 윤곽선 두께
                                  ),
                          ),
                        ),
                        child: Text(
                          topic,
                          style: TextStyle(
                            fontSize: SizeScaler.scaleSize(context, 7),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // 주제 선택란 아래의 구분선
            Container(
              color: const Color(0xFFBABABA), // 구분선 색상
              height: SizeScaler.scaleSize(context, 0.5), // 구분선 두께
            ),
            // 내용 입력 부분
            Padding(
              padding: EdgeInsets.only(left: SizeScaler.scaleSize(context, 11)),
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
    );
  }
}

// 카메라 버튼 구현 필요