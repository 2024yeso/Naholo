import 'package:flutter/material.dart';

class SavePage extends StatefulWidget {
  const SavePage({super.key});

  @override
  State<SavePage> createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  final List<Map<String, dynamic>> savedPlaces = [
    {
      "name": "카페아라",
      "description": "한줄 소개",
      // "image": //"assets/images/cafe_image.png", // 예시 이미지
      "saved": true
    },
    {
      "name": "카페베네",
      "description": "조용한 카페",
      // "image":// "assets/images/cafe_image.png",
      "saved": false
    },
    {
      "name": "커피빈",
      "description": "혼자 책 읽기 좋은 곳",
      //  "image": "assets/images/cafe_image.png",
      "saved": true
    },
    {
      "name": "스타벅스",
      "description": "편안한 공간",
      //   "image": "assets/images/cafe_image.png",
      "saved": false
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가고 싶어요'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: savedPlaces.length,
        itemBuilder: (context, index) {
          final place = savedPlaces[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
              child: Stack(
                children: [
                  Row(
                    children: [
                      // 장소 이미지
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          place["image"] ?? "assets/images/owl.png",
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // 장소 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place["name"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              place["description"],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "장소",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // 우측 상단의 저장된 장소 표시 (하트 아이콘)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        // 하트 클릭 시 저장 상태 변경
                        print('Save button clicked for ${place["name"]}');
                      },
                      child: Icon(
                        place["saved"]
                            ? Icons.favorite // 저장된 경우
                            : Icons.favorite_border, // 저장되지 않은 경우
                        color: place["saved"] ? Colors.red : Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
