import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "http://127.0.0.1:8000";

Future<void> checkId() async {
  // 중복 ID 확인 테스트
  final response = await http.get(Uri.parse('$baseUrl/check_id/?user_id=user123'));

  if (response.statusCode == 200) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    print("중복 ID 여부: ${data['available']}");
  } else {
    print("Check ID Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
  }
}

Future<void> testAddUser() async {
  // 회원가입 테스트
  final response = await http.post(
    Uri.parse('$baseUrl/add_user/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "USER_ID": "test_user",
      "USER_PW": "password123",
      "NAME": "Test User",
      "PHONE": "010-1234-5678",
      "BIRTH": "1990-01-01",
      "GENDER": true,
      "NICKNAME": "Tester",
      "USER_CHARACTER": "Hero",
      "LV": 1,
      "INTRODUCE": "Hello, I am a test user!",
      "IMAGE": 1
    }),
  );

  if (response.statusCode == 200) {
    print("Add User Response: ${utf8.decode(response.bodyBytes)}");
  } else {
    print("Add User Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
  }
}

Future<void> testLoginSuccess() async {
  // 로그인 성공 테스트
  var res;
  final response = await http.get(
    Uri.parse('$baseUrl/login/?user_id=test_user&user_pw=password123'),
  );

  if (response.statusCode == 200) {
    res = jsonDecode(utf8.decode(response.bodyBytes));
    print("Login Success Response: ${res["NICKNAME"]}, ${res["USER_CHARACTER"]}, ${res["LV"]}, ${res["INTRODUCE"]}");
  } else {
    print("Login Success Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
  }
}

Future<void> myPage() async {
  // 마이페이지 테스트
  var res;
  final response = await http.get(
    Uri.parse('$baseUrl/my_page/?user_id=user1'),
  );

  if (response.statusCode == 200) {
    res = jsonDecode(utf8.decode(response.bodyBytes));
    print("reviews: ${res["reviews"]}, wanted: ${res["wanted"]}");
  } else {
    print("Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
  }
}

Future<void> followPage() async {
  // 팔로우페이지 테스트
  var res;
  final response = await http.get(
    Uri.parse('$baseUrl/follow_page/?user_id=user1'),
  );

  if (response.statusCode == 200) {
    res = jsonDecode(utf8.decode(response.bodyBytes));
    print("follow: ${res["follower"]}, follower: ${res["follower"]}");
  } else {
    print("Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
  }
}

  
Future<void> naholoWhere() async {
  // 팔로우페이지 테스트
  var res;
  final response = await http.get(
    Uri.parse('$baseUrl/naholo_where/?user_id=user1'),
  );

  if (response.statusCode == 200) {
    res = jsonDecode(utf8.decode(response.bodyBytes));
    print("follow: ${res["follower"]}, follower: ${res["follower"]}");
  } else {
    print("Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
  }
}

// Top-rated places 테스트 함수 추가
Future<void> testTopRatedPlaces() async {
  final response = await http.get(
    Uri.parse('$baseUrl/where/top-rated'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    print("Top-rated Places by Type:");

    // 'by_type' 데이터를 반복하여 출력
    (data["data"]["by_type"] as Map<String, dynamic>).forEach((type, places) {
      print("\nType: $type");
      for (var place in places) {
        print("Name: ${place['WHERE_NAME']}, Rate: ${place['WHERE_RATE']}, Image: ${place['IMAGE']}");
      }
    });

    // 전체 상위 8개 데이터 출력
    print("\nOverall Top 8 Places:");
    for (var place in data["data"]["overall_top_8"]) {
      print("Name: ${place['WHERE_NAME']}, Rate: ${place['WHERE_RATE']}, Image: ${place['IMAGE']}");
    }

  } else {
    print("Failed to fetch top-rated places: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
  }
}


Future<void> testAddReview() async {
  final response = await http.post(
    Uri.parse('$baseUrl/add_review/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "USER_ID": "user1",
      "WHERE_ID": 1,
      "REVIEW_CONTENT": "Great place with beautiful scenery!",
      "WHERE_LIKE": 10,
      "WHERE_RATE": 4.8,
      "REASON_MENU": true,
      "REASON_MOOD": false,
      "REASON_SAFE": true,
      "REASON_SEAT": false,
      "REASON_TRANSPORT": true,
      "REASON_PARK": true,
      "REASON_LONG": false,
      "REASON_VIEW": true,
      "REASON_INTERACTION": false,
      "REASON_QUITE": true,
      "REASON_PHOTO": true,
      "REASON_WATCH": false,
      "IMAGES": ["scenery1.jpg", "scenery2.jpg"] // 리뷰와 함께 추가할 이미지들
    }),
  );

  if (response.statusCode == 200) {
    print("Add Review Response: ${utf8.decode(response.bodyBytes)}");
  } else {
    print("Add Review Failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
  }
}


// /journal/main 엔드포인트 테스트 함수
Future<void> testJournalMain() async {
  final response = await http.get(
    Uri.parse('$baseUrl/journal/main'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    print("Journal Main Data:");

    // 최신순 10개의 일지 데이터를 반복하여 출력
    print("\nLatest 10 Journal Posts:");
    for (var post in data["data"]["latest_10"]) {
      print(
          "Post Name: ${post['POST_NAME']}, User: ${post['USER_ID']}, Likes: ${post['POST_LIKE']}, Image: ${post['USER_IMAGE']}, UPDATED:${post['POST_UPDATE']}");
    }

    // 인기순 10개의 일지 데이터를 반복하여 출력
    print("\nTop 10 Journal Posts by Likes:");
    for (var post in data["data"]["top_10"]) {
      print(
          "Post Name: ${post['POST_NAME']}, User: ${post['USER_ID']}, Likes: ${post['POST_LIKE']}, Image: ${post['USER_IMAGE']},UPDATED:${post['POST_UPDATE']}");
    }

  } else {
    print("Failed to fetch journal main data: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
  }
}


// /journal/post_comment 엔드포인트 테스트 함수
Future<void> testGetJournalComments(int postId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/journal/post_comment?post_id=$postId'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    print("Comments for Post ID $postId:");

    // 댓글 데이터를 반복하여 출력
    for (var comment in data["comments"]) {
      print(
          "Comment ID: ${comment['COMMENT_ID']}, User: ${comment['USER_ID']}, Nickname: ${comment['NICKNAME']}, "
          "Content: ${comment['COMMENT_CONTENT']}, Level: ${comment['LV']}, Character: ${comment['USER_CHARACTER']}");
    }
  } else {
    print("Failed to fetch comments: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
  }
}

// /where/place-info 엔드포인트 테스트 함수
Future<void> testGetPlaceInfo(int whereId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/where/place-info?where_id=$whereId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      print("Place Info:");

      // 장소 정보 출력, null 체크 추가
      final placeInfo = data["place_info"];
      if (placeInfo != null) {
        print(
            "Name: ${placeInfo['WHERE_NAME'] ?? 'Unknown'}, Location: ${placeInfo['WHERE_LOCATE'] ?? 'Unknown'}, Rate: ${placeInfo['WHERE_RATE'] ?? 'Unknown'}");
      } else {
        print("Place info is not available.");
      }

      // 리뷰 정보 그룹화
      Map<int, Map<String, dynamic>> groupedReviews = {};

      // Null safety 적용
      if (data["reviews"] != null) {
        for (var review in data["reviews"]) {
          int? reviewId = review['REVIEW_ID'];

          if (reviewId != null && !groupedReviews.containsKey(reviewId)) {
            // 리뷰가 처음 등장한 경우, 리뷰 정보 추가
            groupedReviews[reviewId] = {
              "REVIEW_ID": reviewId,
              "USER_ID": review['USER_ID'] ?? 'Unknown',
              "REVIEW_CONTENT": review['REVIEW_CONTENT'] ?? 'No content',
              "WHERE_RATE": review['WHERE_RATE'] ?? 0,
              "IMAGES": <String>[]
            };
          }

          // 리뷰 이미지가 있을 경우 리스트에 추가
          if (review['REVIEW_IMAGE'] != null && reviewId != null) {
            groupedReviews[reviewId]?["IMAGES"].add(review['REVIEW_IMAGE']);
          }
        }
      } else {
        print("No reviews found.");
      }

      // 그룹화된 리뷰 출력
      print("\nReviews:");
      groupedReviews.forEach((id, review) {
        print(
            "Review ID: ${review['REVIEW_ID']}, User: ${review['USER_ID']}, Content: ${review['REVIEW_CONTENT']}, Rate: ${review['WHERE_RATE']}");
        print("Review Images: ${review['IMAGES']}");
      });
    } else {
      print(
          "Failed to fetch place info: ${response.statusCode} ${utf8.decode(response.bodyBytes)}");
    }
  } catch (e) {
    print("An error occurred: $e");
  }
}

void main() async {
/*
  print("=== Testing ID Check ===");
  await checkId();

  print("\n=== Testing User Registration ===");
  await testAddUser();

  await myPage();
  await followPage();
  await testTopRatedPlaces();
  await testAddReview();

  print("\n=== Testing Login Failure (Wrong Password) ===");
  await testLoginFailureWrongPassword();

  print("\n=== Testing Login Failure (Nonexistent User) ===");
  await testLoginFailureNonexistentUser();
*/

  await testGetPlaceInfo(1);
}
