import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nahollo/api/api.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:nahollo/sizeScaler.dart';

class SavePage extends StatefulWidget {
  const SavePage({super.key});

  @override
  State<SavePage> createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  List likedPlaces = []; // 좋아요한 장소 리스트
  bool isLoading = true; // 로딩 상태 관리
  String? errorMessage;
  List<Map<String, dynamic>> savedPlaces = []; // 데이터를 저장할 리스트

  // API를 호출하여   데이터를 가져오는 함수
  Future<void> fetchLikedPlaces() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user!.userId;

    final String url = '${Api.baseUrl}/user_likes/$userId'; // 서버의 엔드포인트 주소

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body); // JSON 응답을 디코드
        setState(() {
          likedPlaces = data['liked_places']; // 장소 데이터를 상태에 저장
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = "No likes found for this user.";
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to fetch liked places.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: $e";
        isLoading = false;
      });
    }

    List<Map<String, dynamic>> tempPlaces = likedPlaces.map((place) {
      return {
        "id": place["WHERE_ID"],
        "name": utf8.decode(place["WHERE_NAME"].codeUnits), // 이름 디코딩
        "location": utf8.decode(place["WHERE_LOCATE"].codeUnits), // 위치 디코딩
        "image": base64Decode(place["WHERE_IMAGE"]), // Base64 이미지 디코딩
        "saved": true // 기본값으로 저장된 상태
      };
    }).toList();

    setState(() {
      savedPlaces = tempPlaces; // 디코딩된 데이터 저장
    });
  }

  // 장소 저장 상태를 토글하는 함수
  void savePlace(String placeId, BuildContext context, int index) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user!.userId;

    const String url = '${Api.baseUrl}/toggle_like'; // API 엔드포인트 주소

    try {
      // API 호출: 서버로 좋아요 토글 요청 보내기
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId, // 사용자 ID
          'where_id': placeId // 장소 ID
        }),
      );

      if (response.statusCode == 200) {
        // 서버로부터 받은 응답을 처리 (add/remove)
        final responseBody = json.decode(response.body);
        if (responseBody['message'] == 'add') {
          print('Place successfully liked!');
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Place liked!')));

          // UI 업데이트: 하트 상태를 변경 (true)
          setState(() {
            savedPlaces[index]['saved'] = true;
          });
        } else if (responseBody['message'] == 'remove') {
          print('Place successfully unliked!');
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Place unliked!')));

          // UI 업데이트: 리스트에서 해당 장소를 제거
          setState(() {
            savedPlaces.removeAt(index); // 해당 인덱스의 장소 제거
          });
        }
      } else {
        print('Failed to toggle like: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to toggle like.')));
      }
    } catch (e) {
      print('Error toggling like: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error toggling like.')));
    }
  }

  String _sortLabel = '   최신순 ';

  @override
  void initState() {
    super.initState();
    fetchLikedPlaces(); // initState에서 데이터 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: SizeScaler.scaleSize(context, 38),
        title: Text(
          '가고 싶어요',
          style: TextStyle(
            fontSize: SizeScaler.scaleSize(context, 8.8),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(right: SizeScaler.scaleSize(context, 7)),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: SizeScaler.scaleSize(context, 8)),
                          ListTile(
                            title: Text('   최신순 '),
                            onTap: () {
                              setState(() {
                                _sortLabel = '   최신순 ';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('   인기순 '),
                            onTap: () {
                              setState(() {
                                _sortLabel = '   인기순 ';
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  width: SizeScaler.scaleSize(context, 40),
                  height: SizeScaler.scaleSize(context, 15),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFFD1D1D1),
                        width: SizeScaler.scaleSize(context, 0.3)),
                    borderRadius: BorderRadius.circular(
                        SizeScaler.scaleSize(context, 7.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 수평 중앙 정렬
                    crossAxisAlignment: CrossAxisAlignment.center, // 수직 중앙 정렬
                    children: [
                      Text(
                        '   최신순 ',
                        style: TextStyle(
                          fontSize: SizeScaler.scaleSize(context, 6),
                          fontWeight: FontWeight.w500,
                          color: Colors.black, // const Color(0xFFA0A0A0),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down, // 최신순 선택을 위한 아이콘
                        size: SizeScaler.scaleSize(context, 11.25), // 크기 조정
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 8)),
          Container(
            color: const Color(0xFFD9D9D9), // 타이틀 회색 구분선 색상
            height: SizeScaler.scaleSize(context, 0.3), // 구분선 두께
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator()) // 데이터 로딩 중
                : savedPlaces.isEmpty
                    ? const Center(child: Text('No saved places found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: savedPlaces.length,
                        itemBuilder: (context, index) {
                          final place = savedPlaces[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.0), // 수정
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                              child: Stack(
                                children: [
                                  Row(
                                    children: [
                                      // 장소 이미지 표시
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            SizeScaler.scaleSize(context, 6)),
                                        child: Image.memory(
                                          place["image"], // Base64 디코딩된 이미지
                                          width:
                                              SizeScaler.scaleSize(context, 50),
                                          height:
                                              SizeScaler.scaleSize(context, 50),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(
                                          width:
                                              SizeScaler.scaleSize(context, 9)),
                                      // 장소 정보 표시
                                      SizedBox(
                                        height:
                                            SizeScaler.scaleSize(context, 45),
                                        child: Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                place["name"], // 디코딩된 장소 이름
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize:
                                                      SizeScaler.scaleSize(
                                                          context, 8),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                place["location"], // 디코딩된 장소 위치
                                                style: TextStyle(
                                                  color:
                                                      const Color(0xff949494),
                                                  fontSize:
                                                      SizeScaler.scaleSize(
                                                          context, 6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // 우측 상단에 저장된 상태를 나타내는 하트 아이콘
                                  // 우측 상단에 저장된 상태를 나타내는 하트 아이콘
                                  Positioned(
                                    top: SizeScaler.scaleSize(context, 1.5),
                                    left: SizeScaler.scaleSize(context, 36.5),
                                    child: GestureDetector(
                                      onTap: () {
                                        // 하트 아이콘 클릭 시 상태 변경 (index 전달)
                                        savePlace(place["id"], context, index);
                                      },
                                      child: Icon(
                                          place["saved"]
                                              ? Icons.bookmark // 저장된 상태
                                              : Icons
                                                  .bookmark_border, // 저장되지 않은 상태
                                          color: const Color(
                                              0xff7a4fff), // 북마크 아이콘 색상
                                          size: SizeScaler.scaleSize(
                                              context, 13) // 아이콘 크기
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
