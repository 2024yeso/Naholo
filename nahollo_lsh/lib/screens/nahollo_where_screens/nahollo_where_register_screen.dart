import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/providers/user_provider.dart';

import 'package:http/http.dart' as http;
import 'package:nahollo/screens/nahollo_where_screens/nahollo_where_register_search_screen.dart';
import 'package:nahollo/util.dart';
import 'package:provider/provider.dart';

class NaholloWhereRegisterScreen extends StatefulWidget {
  const NaholloWhereRegisterScreen({super.key});

  @override
  State<NaholloWhereRegisterScreen> createState() =>
      _NaholloWhereRegisterScreenState();
}

class _NaholloWhereRegisterScreenState
    extends State<NaholloWhereRegisterScreen> {
  final TextEditingController _memoController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  double _rating = 0;

  final Map<String, bool> _reasons = {
    "1인 메뉴가 좋아요": false,
    "분위기가 좋아요": false,
    "위생관리 잘돼요": false,
    "혼자 즐기 좋은 음식이 있어요": false,
    "대중교통으로 가기 편해요": false,
    "주차 가능해요": false,
    "오래 머물기 좋아요": false,
    "날씨가 좋아요": false,
    "고독할 수 있어요": false,
    "활발히 놀기좋아요": false,
    "사진 찍기 좋아요": false,
    "구경할 거 있어요": false,
  };

  Future<void> testAddReview() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    final response = await http.post(
      Uri.parse('${Api.baseUrl}/add_review/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "USER_ID": "${user?.userId}",
        "WHERE_ID": 1,
        "REVIEW_CONTENT": _memoController.text.trim(),
        "WHERE_LIKE": 10,
        "WHERE_RATE": _rating,
        "REASON_MENU": _reasons["1인 메뉴가 좋아요"] ?? false,
        "REASON_MOOD": _reasons["분위기가 좋아요"] ?? false,
        "REASON_SAFE": _reasons["위생관리 잘돼요"] ?? false,
        "REASON_SEAT": _reasons["혼자 즐기 좋은 음식이 있어요"] ?? false,
        "REASON_TRANSPORT": _reasons["대중교통으로 가기 편해요"] ?? false,
        "REASON_PARK": _reasons["주차 가능해요"] ?? false,
        "REASON_LONG": _reasons["오래 머물기 좋아요"] ?? false,
        "REASON_VIEW": _reasons["날씨가 좋아요"] ?? false,
        "REASON_INTERACTION": _reasons["고독할 수 있어요"] ?? false,
        "REASON_QUITE": _reasons["활발히 놀기좋아요"] ?? false,
        "REASON_PHOTO": _reasons["사진 찍기 좋아요"] ?? false,
        "REASON_WATCH": _reasons["구경할 거 있어요"] ?? false,
        "IMAGES": ["scenery1.jpg", "scenery2.jpg"] // 리뷰와 함께 추가할 이미지들
      }),
    );

    if (response.statusCode == 200) {
      print("Add Review Response: ${utf8.decode(response.bodyBytes)}");
    } else {
      print(
          "Add Review Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _selectedImages = pickedFiles.map((e) => File(e.path)).toList();
    });
  }

  Future<void> _submitReview() async {
    await testAddReview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나홀로 어디? 등록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '나홀로 어디? 사진 0/20',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImages.isEmpty
                    ? const Center(
                        child: Text('+\n사진 선택', textAlign: TextAlign.center))
                    : Image.file(_selectedImages[0], fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '다녀온 나홀로 어디?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // 장소 선택 로직 추가
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const NaholloWhereRegisterSearchScreen()),
                );
              },
              child: const Text(
                '장소를 검색해주세요',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '나홀로 가기 좋은 이유',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _reasons.keys.map((reason) {
                return FilterChip(
                  label: Text(reason),
                  selected: _reasons[reason]!,
                  onSelected: (bool selected) {
                    setState(() {
                      _reasons[reason] = selected;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              '별점 리뷰',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            Text('$_rating'),
            const SizedBox(height: 16),
            const Text(
              '나홀로 메모',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _memoController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    '취향에 맞는 장소였나요? 장점의 묘미, 즐길 거리 등 혼자 방문하기 좋은 이유를 기록해보세요.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('나홀로 어디? 등록'),
            ),
          ],
        ),
      ),
    );
  }
}
