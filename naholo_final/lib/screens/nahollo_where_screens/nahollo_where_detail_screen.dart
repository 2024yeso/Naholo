import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:nahollo/api/api.dart'; // API 경로를 위한 import 추가
import 'package:nahollo/models/review.dart';
import 'package:nahollo/screens/mypage_screens/your_profile.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/util.dart';
import 'package:http/http.dart' as http; // HTTP 요청을 위한 import 추가
import 'package:provider/provider.dart'; // Provider를 사용하기 위한 import 추가
import 'package:fluttertoast/fluttertoast.dart'; // Toast 메시지를 위한 import 추가
import 'package:nahollo/providers/user_provider.dart'; // UserProvider import 추가

class NaholloWhereDetailScreen extends StatefulWidget {
  final String whereId;

  const NaholloWhereDetailScreen({super.key, required this.whereId});

  @override
  State<NaholloWhereDetailScreen> createState() =>
      _NaholloWhereDetailScreenState();
}

class _NaholloWhereDetailScreenState extends State<NaholloWhereDetailScreen> {
  Map<String, dynamic>? info; // 장소 상세 정보를 저장할 변수
  List<Map<String, dynamic>> reviews = []; // 리뷰 리스트
  final bool _isLoading = true;
  bool isLoading = true; // 데이터 로딩 상태
  bool _isSave = false;
  String? errorMessage;
  List likedPlaces = []; // 좋아요한 장소 리스트

  String showAdress(String adress) {
    var list = adress.split(' ');

    // 리스트가 2개 이상의 항목을 가지는지 확인
    if (list.length < 2) return adress;

    // 리스트가 3개 이상의 항목을 가지는지 확인 후 안전하게 접근
    var part1 = list.length > 1 ? list[1] : '';
    var part2 = list.length > 2 ? ', ${list[2]}' : '';

    var result = '$part1$part2';
    return result;
  }

  void saveButton() {
    setState(() {
      _isSave = !_isSave;
    });
  }

  Future<void> fetchLikedPlaces() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user!.userId;

    final String url = '${Api.baseUrl}/user_likes/$userId'; // 서버의 엔드포인트 주소

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          likedPlaces = data['liked_places'];

          // '가고 싶어요' 상태를 현재 장소에 맞춰 설정
          _isSave =
              likedPlaces.any((place) => place['WHERE_ID'] == widget.whereId);
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
  }

// 장소 저장 상태를 토글하는 함수
  Future<void> savePlace() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user!.userId; // 사용자 ID

    const String url = '${Api.baseUrl}/toggle_like'; // API 엔드포인트 주소

    try {
      // API 호출: 서버로 "가고 싶어요" 토글 요청 보내기
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId, // 사용자 ID
          'where_id': widget.whereId // 장소 ID
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        setState(() {
          if (responseBody['message'] == 'add') {
            Fluttertoast.showToast(msg: '이 장소를 가고 싶어요 목록에 추가했습니다!');
            _isSave = true; // '가고 싶어요' 상태를 true로 변경
            info!["SAVE"] = (info!["SAVE"] ?? 0) + 1; // 저장된 수 업데이트
          } else if (responseBody['message'] == 'remove') {
            Fluttertoast.showToast(msg: '이 장소를 가고 싶어요 목록에서 제거했습니다.');
            _isSave = false; // '가고 싶어요' 상태를 false로 변경
            info!["SAVE"] = (info!["SAVE"] ?? 0) - 1; // 저장된 수 감소
          }
        });
      } else {
        Fluttertoast.showToast(msg: '서버와 통신하는 데 실패했습니다.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '에러가 발생했습니다: $e');
    }
  }

  Future<Map<String, dynamic>> getReviewadd(Map<String, dynamic> review) async {
    String userId = review["USER_ID"];

    try {
      print("사용자 ID: $userId");
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/my_page/?user_id=$userId'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        String nickname =
            data['user_info'] != null ? data['user_info']['NICKNAME'] : "오류1";

        Uint8List? imageBytes;
        try {
          if (data['user_info'] != null && data['user_info']['IMAGE'] != null) {
            String base64Image =
                data['user_info']['IMAGE'].replaceAll(RegExp(r'\s+'), '');
            imageBytes = base64Decode(base64Image);
          } else {
            imageBytes = null;
          }
        } catch (e) {
          print('base64 디코딩 에러: $e');
          imageBytes = null; // 디코딩 실패 시 null로 처리
        }

        int lv = data['user_info'] != null ? data['user_info']['LV'] : 0;

        return {
          'nickname': nickname,
          'imageBytes': imageBytes,
          'lv': lv,
        };
      } else {
        print('서버 응답 에러: ${response.statusCode}');
        return {
          'nickname': '오류2',
          'imageBytes': null,
          'lv': 0,
        };
      }
    } catch (e) {
      print('데이터 가져오기 에러: $e');
      return {
        'nickname': '오류3',
        'imageBytes': null,
        'lv': 0,
      };
    }
  }

  Widget buildRatingBar(BuildContext context, double rating) {
    return Row(
      children: [
        Container(
          width: SizeScaler.scaleSize(context, 39),
          height: SizeScaler.scaleSize(context, 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                offset: const Offset(2, 2),
                blurRadius: 2,
                spreadRadius: 2,
              )
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: RatingBarIndicator(
                itemSize: 8,
                rating: rating, // 전달받은 평점 값 사용
                direction: Axis.horizontal,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(
                  horizontal: SizeScaler.scaleSize(context, 1),
                ), // 별 사이의 간격 조정
                itemBuilder: (context, _) => Image.asset(
                  "assets/images/star.png",
                  height: SizeScaler.scaleSize(context, 20),
                  width: SizeScaler.scaleSize(context, 20),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: SizeScaler.scaleSize(context, 6),
        ),
        Text(
          rating.toStringAsFixed(1), // 소수점 첫 번째 자리까지 표시
          style: TextStyle(
            color: Colors.grey,
            fontSize: SizeScaler.scaleSize(context, 5),
          ),
        ),
      ],
    );
  }

  Widget buildRatingBar2(BuildContext context, double rating) {
    return Row(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: RatingBarIndicator(
              itemSize: 8,
              rating: rating, // 전달받은 평점 값 사용
              direction: Axis.horizontal,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(
                horizontal: SizeScaler.scaleSize(context, 1),
              ), // 별 사이의 간격 조정
              itemBuilder: (context, _) => Image.asset(
                "assets/images/star.png",
                height: SizeScaler.scaleSize(context, 30),
                width: SizeScaler.scaleSize(context, 30),
              ),
            ),
          ),
        ),
        SizedBox(
          width: SizeScaler.scaleSize(context, 6),
        ),
        Text(
          rating.toStringAsFixed(1), // 소수점 첫 번째 자리까지 표시
          style: TextStyle(
            color: Colors.grey,
            fontSize: SizeScaler.scaleSize(context, 5),
          ),
        ),
      ],
    );
  }

  // 이유별 카운트를 저장할 맵
  final Map<String, int> _reasonCounts = {};

  // 이유 목록과 대응되는 한글 텍스트 맵
  final Map<String, String> reasonTextMap = {
    "MENU": "1인 메뉴가 좋아요",
    "MOOD": "분위기가 좋아요",
    "SAFE": "위생관리 잘돼요",
    "SEAT": "좌석이 편해요",
    "TRANSPORT": "대중교통으로 가기 편해요",
    "PARK": "주차 가능해요",
    "LONG": "오래 머물기 좋아요",
    "VIEW": "경치가 좋아요",
    "INTERACTION": "교류하기 좋아요",
    "QUITE": "조용해요",
    "PHOTO": "사진 찍기 좋아요",
    "WATCH": "구경할 거 있어요",
  };

  @override
  void initState() {
    super.initState();
    fetchData(); // 데이터 가져오기
    fetchLikedPlaces(); // '가고 싶어요' 상태 업데이트
  }

  Future<void> fetchData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      String userId = user?.userId ?? '';

      // 장소 상세 정보 가져오기
      final whereResponse = await http.get(
        Uri.parse("${Api.baseUrl}/where/${widget.whereId}"),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8'
        },
      );

      // 리뷰 정보 가져오기 (user_id를 쿼리 파라미터로 전달)
      final reviewResponse = await http.get(
        Uri.parse(
            "${Api.baseUrl}/where/${widget.whereId}/reviews?user_id=$userId"),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8'
        },
      );

      if (whereResponse.statusCode == 200 && reviewResponse.statusCode == 200) {
        setState(() {
          info = jsonDecode(utf8.decode(whereResponse.bodyBytes))["data"];
          reviews = List<Map<String, dynamic>>.from(
              jsonDecode(utf8.decode(reviewResponse.bodyBytes))["data"]);
          print('Received Reviews: $reviews');

          // 리뷰별로 이미지 데이터 확인
          for (var review in reviews) {
            print(
                'Review ID: ${review["REVIEW_ID"]}, Images: ${review["REVIEW_IMAGES"]}');

            // REVIEW_LIKE와 isLiked 초기화
            review["REVIEW_LIKE"] = review["REVIEW_LIKE"] ?? 0;

            var isLikedValue = review["isLiked"] ?? false;
            // isLikedValue가 int 타입인 경우 bool로 변환
            if (isLikedValue is int) {
              review["isLiked"] = isLikedValue == 1;
            } else {
              review["isLiked"] = isLikedValue == true;
            }
          }

          calculateReasonCounts(); // 이유별 카운트 계산
          isLoading = false;
        });
      } else {
        // 에러 처리
        print(
            "Failed to load data: Status Code - ${whereResponse.statusCode}, ${reviewResponse.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // 이유별 카운트를 계산하는 함수
  void calculateReasonCounts() {
    _reasonCounts.clear();

    for (var review in reviews) {
      for (var reasonKey in reasonTextMap.keys) {
        String reviewReasonKey = 'REASON_$reasonKey';
        if (review[reviewReasonKey] == true || review[reviewReasonKey] == 1) {
          _reasonCounts[reasonKey] = (_reasonCounts[reasonKey] ?? 0) + 1;
        }
      }
    }
  }

  Widget showReasonChips() {
    return Wrap(
      spacing: 0.0, // 아이템들 사이의 간격
      children: _reasonCounts.entries
          .where((entry) => entry.value > 0) // value가 0 이상인 항목만 필터링
          .map((entry) {
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: SizeScaler.scaleSize(context, 1),
              vertical: SizeScaler.scaleSize(context, 1.5)),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeScaler.scaleSize(context, 7),
              vertical: SizeScaler.scaleSize(context, 3),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  const Color(0xffFFD6F9).withOpacity(0.4),
                  const Color(0xff9389FF).withOpacity(0.4),
                  const Color(0xffEAC5FF).withOpacity(0.5),
                  const Color(0xffFFF1C5).withOpacity(0.5),
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reasonTextMap[entry.key] ?? entry.key, // 이유 텍스트
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: SizeScaler.scaleSize(context, 6)), // 텍스트 스타일 설정
                ),
                const SizedBox(width: 5), // 약간의 간격
                Text(
                  entry.value.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                  ), // 숫자는 약간 다르게 스타일링
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // 하트를 눌렀을 때 실행할 함수
  void toggleLike(int index) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    String userId = user?.userId ?? '';

    if (userId.isEmpty) {
      Fluttertoast.showToast(msg: "로그인이 필요합니다.");
      return;
    }

    // 현재 좋아요 상태를 가져와서 bool 타입으로 변환
    bool currentIsLiked;
    var isLikedValue = reviews[index]["isLiked"] ?? false;

    if (isLikedValue is int) {
      currentIsLiked = isLikedValue == 1;
    } else {
      currentIsLiked = isLikedValue == true;
    }

    // 좋아요 상태를 토글
    bool newIsLiked = !currentIsLiked;

    // UI에 즉시 반영
    setState(() {
      reviews[index]["isLiked"] = newIsLiked;
      if (newIsLiked) {
        reviews[index]["REVIEW_LIKE"] =
            (reviews[index]["REVIEW_LIKE"] ?? 0) + 1;
      } else {
        reviews[index]["REVIEW_LIKE"] =
            (reviews[index]["REVIEW_LIKE"] ?? 0) - 1;
      }
    });

    // 서버로 좋아요 상태를 전송
    try {
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/reviews/${reviews[index]['REVIEW_ID']}/like"),
        headers: {
          'Content-Type': 'application/json',
          'Accept-Charset': 'utf-8'
        },
        body: jsonEncode({
          'user_id': userId,
          'like': newIsLiked,
        }),
      );

      if (response.statusCode != 200) {
        // 서버 응답이 실패하면 상태를 원래대로 복구
        setState(() {
          reviews[index]["isLiked"] = currentIsLiked;
          if (currentIsLiked) {
            reviews[index]["REVIEW_LIKE"] =
                (reviews[index]["REVIEW_LIKE"] ?? 0) + 1;
          } else {
            reviews[index]["REVIEW_LIKE"] =
                (reviews[index]["REVIEW_LIKE"] ?? 0) - 1;
          }
        });
        Fluttertoast.showToast(msg: "좋아요 처리에 실패했습니다.");
      } else {
        // 서버 응답이 성공하면 서버에서 받은 최신 좋아요 수를 업데이트
        final responseData = jsonDecode(response.body);
        setState(() {
          reviews[index]["REVIEW_LIKE"] =
              responseData["REVIEW_LIKE"] ?? reviews[index]["REVIEW_LIKE"];
        });
      }
    } catch (e) {
      // 예외 발생 시 상태를 원래대로 복구
      setState(() {
        reviews[index]["isLiked"] = currentIsLiked;
        if (currentIsLiked) {
          reviews[index]["REVIEW_LIKE"] =
              (reviews[index]["REVIEW_LIKE"] ?? 0) + 1;
        } else {
          reviews[index]["REVIEW_LIKE"] =
              (reviews[index]["REVIEW_LIKE"] ?? 0) - 1;
        }
      });
      Fluttertoast.showToast(msg: "좋아요 처리 중 오류가 발생했습니다.");
    }
  }

  // 이미지 데이터를 표시하는 위젯
  Widget buildImage(dynamic imageData, double width, double height) {
    if (imageData != null) {
      if (imageData is String && imageData.isNotEmpty) {
        // Base64 데이터가 'data:image' 접두사를 가지고 있는지 확인 후 제거
        String base64String = imageData;
        if (imageData.startsWith('data:image')) {
          base64String = imageData.split(',').last;
        }

        try {
          // Base64 데이터를 디코딩
          Uint8List imageBytes = base64Decode(base64String);

          // 디버그 로그로 디코딩된 이미지 크기 확인
          print('Decoded image size: ${imageBytes.length} bytes');

          // 디코딩된 이미지가 유효한지 확인하기 위해 메모리에 로드
          return Image.memory(
            imageBytes,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // 디코딩에 실패하거나 이미지 로딩 중 에러 발생 시 대체 이미지 표시
              print('Error displaying image: $error');
              return Image.asset(
                'assets/images/default_image.png',
                width: width,
                height: height,
                fit: BoxFit.cover,
              );
            },
          );
        } catch (e) {
          print('Base64 decoding error: $e');
          return Image.asset(
            'assets/images/default_image.png',
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        }
      } else if (imageData is Uint8List || imageData is List<int>) {
        // Uint8List 또는 List<int>인 경우
        Uint8List imageBytes =
            imageData is Uint8List ? imageData : Uint8List.fromList(imageData);
        return Image.memory(
          imageBytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error displaying image: $error');
            return Image.asset(
              'assets/images/default_image.png',
              width: width,
              height: height,
              fit: BoxFit.cover,
            );
          },
        );
      } else {
        // 지원하지 않는 데이터 타입인 경우 대체 이미지 표시
        print('Unsupported image data type: ${imageData.runtimeType}');
        return Image.asset(
          'assets/images/default_image.png',
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      }
    } else {
      // 이미지 데이터가 없을 경우 기본 이미지 표시
      print('No image data provided.');
      return Image.asset(
        'assets/images/default_image.png',
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (isLoading) {
      // 데이터 로딩 중이면 로딩 인디케이터 표시
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (info == null) {
      // 데이터 로딩 실패 시 에러 메시지 표시
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomBottomNavBar(
        selectedIndex: 0,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          info!["WHERE_NAME"],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: SizeScaler.scaleSize(context, 9),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 장소 이미지
              SizedBox(
                width: SizeScaler.scaleSize(context, 197),
                height: SizeScaler.scaleSize(context, 135),
                child: buildImage(
                    info!["WHERE_IMAGE"], double.infinity, double.infinity),
              ),
              SizedBox(
                height: SizeScaler.scaleSize(context, 10),
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: SizeScaler.scaleSize(context, 15)),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "혼자 놀기 좋아요!",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Color(0xff7f7f7f),
                                  fontWeight: FontWeight.bold),
                            ),
                            AutoSizeText(
                              "${info!["WHERE_NAME"]}",
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              maxLines: 1,
                              minFontSize: 10,
                            ),
                            Text(
                              showAdress(
                                info!["WHERE_LOCATE"],
                              ),
                              style: TextStyle(
                                color: const Color(0xff7f7f7f),
                                fontSize: SizeScaler.scaleSize(context, 9),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  info!["SAVE"] == null
                                      ? "8명이 이 장소를 저장했어요"
                                      : "${info!["SAVE"]}명이 이 장소를 저장했어요",
                                  style: TextStyle(
                                    color: const Color(0xff7f7f7f),
                                    fontSize: SizeScaler.scaleSize(context, 8),
                                  ),
                                ),
                                SizedBox(
                                  width: SizeScaler.scaleSize(context, 10),
                                ),
                                buildRatingBar(context, info!["WHERE_RATE"])
                              ],
                            )
                          ],
                        ),

                        // 이미지 오른쪽 상단에 저장하기 버튼
                        Positioned(
                          top: 5,
                          right: -5,
                          child: IconButton(
                            icon: Icon(
                              _isSave
                                  ? Icons.bookmark
                                  : Icons
                                      .bookmark_border, // _isSave 값에 따라 아이콘 변경
                              size: 30,
                              color: const Color(0xff7a4fff),
                            ),
                            onPressed: () {
                              savePlace(); // 버튼 클릭 시 서버로 상태 전송
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeScaler.scaleSize(context, 2),
              ),
              // 장소 설명
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  info!["WHERE_DESCRIPTION"] ?? "",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              // 이유 칩들 표시
              showReasonChips(),
              const SizedBox(height: 20),
              // 리뷰 리스트
              Column(
                children: reviews.map((review) {
                  // True인 REASON 값만 필터링
                  final trueReasons = reasonTextMap.entries
                      .where((entry) =>
                          review['REASON_${entry.key}'] == true ||
                          review['REASON_${entry.key}'] == 1)
                      .map((entry) => entry.value)
                      .toList();

                  // 리뷰의 이미지 리스트 가져오기
                  List<dynamic> reviewImages = [];
                  if (review["REVIEW_IMAGES"] != null &&
                      review["REVIEW_IMAGES"].isNotEmpty) {
                    reviewImages = review["REVIEW_IMAGES"];
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 상단 사용자 정보 및 태그
                          Row(
                            children: [
                              FutureBuilder<Map<String, dynamic>>(
                                future: getReviewadd(review), // 비동기 데이터 호출
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey[300],
                                      child: const Icon(Icons.person,
                                          size: 20, color: Colors.white),
                                    );
                                  } else if (snapshot.hasError) {
                                    return CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey[300],
                                      child: const Icon(Icons.error,
                                          size: 20, color: Colors.red),
                                    );
                                  } else if (snapshot.hasData) {
                                    final data = snapshot.data!;
                                    final nickname = data['nickname'];
                                    final imageBytes = data['imageBytes'];
                                    final lv = data['lv'];

                                    return Row(
                                      children: [
                                        SizedBox(
                                          width:
                                              SizeScaler.scaleSize(context, 20),
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              if (user!.userId !=
                                                  review["USER_ID"]
                                                      .toString()) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          YourProfile(
                                                        user_id:
                                                            review["USER_ID"],
                                                      ),
                                                    ));
                                              }
                                            },
                                            child: ClipOval(
                                              child: imageBytes != null
                                                  ? Image.memory(
                                                      imageBytes!,
                                                      width:
                                                          SizeScaler.scaleSize(
                                                              context, 20),
                                                      height:
                                                          SizeScaler.scaleSize(
                                                              context, 20),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      'assets/images/default_image.png', // 기본 이미지 경로
                                                      width:
                                                          SizeScaler.scaleSize(
                                                              context, 20),
                                                      height:
                                                          SizeScaler.scaleSize(
                                                              context, 20),
                                                      fit: BoxFit.cover,
                                                    ),
                                            )),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              nickname,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Lv.$lv',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  } else {
                                    return CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey[300],
                                      child: const Icon(Icons.person,
                                          size: 20, color: Colors.white),
                                    );
                                  }
                                },
                              ),
                              const Spacer(),
                            ],
                          ),
                          // 이미지 스크롤
                          if (reviewImages.isNotEmpty)
                            SizedBox(
                              height: SizeScaler.scaleSize(context, 147),
                              width: SizeScaler.scaleSize(context, 147),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: reviewImages.length,
                                itemBuilder: (context, imgIndex) {
                                  // 이미지 데이터를 가져오기
                                  final imageData = reviewImages[imgIndex];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: buildImage(
                                      imageData,
                                      SizeScaler.scaleSize(context, 147),
                                      SizeScaler.scaleSize(context, 147),
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 15),
                          // 리뷰 내용
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              review["REVIEW_CONTENT"],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xff7e7e7e),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(children: [
                            SizedBox(
                              width: SizeScaler.scaleSize(
                                  context, SizeScaler.scaleSize(context, 10)),
                            ),
                            buildRatingBar2(context, review["WHERE_RATE"])
                          ]),

                          const SizedBox(height: 12),
                          // True인 REASON들 표시
                          Wrap(
                            spacing: 6.0,
                            children: trueReasons
                                .map((reason) => Padding(
                                      padding: EdgeInsets.only(
                                        bottom:
                                            SizeScaler.scaleSize(context, 3),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0,
                                            vertical: 8.0), // Chip의 패딩과 유사하게 설정
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: const Color(
                                                0xff7e7e7e), // 검정색 테두리 추가
                                            width: 1.0, // 테두리 두께 설정
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              20), // Chip과 같은 둥근 모서리
                                        ),
                                        child: Text(reason,
                                            style: TextStyle(
                                                fontSize: SizeScaler.scaleSize(
                                                    context, 6),
                                                color: const Color(
                                                    0xff7e7e7e))), // 텍스트 스타일
                                      ),
                                    ))
                                .toList(),
                          ),

                          // 좋아요 및 하트 이모티콘
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: Icon(
                                  (review["isLiked"] == true ||
                                          review["isLiked"] == 1)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: (review["isLiked"] == true ||
                                          review["isLiked"] == 1)
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  toggleLike(reviews.indexOf(review));
                                },
                              ),
                              Text(
                                "${review["REVIEW_LIKE"] ?? 0}명이 이 후기를 좋아합니다",
                                style:
                                    const TextStyle(color: Color(0xff7e7e7e)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
