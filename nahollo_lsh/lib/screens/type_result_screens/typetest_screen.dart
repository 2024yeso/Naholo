import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nahollo/colors.dart';
import 'package:nahollo/screens/type_result_screens/analyzing_results_screen.dart';
import 'package:nahollo/util.dart';

class TypetestScreen extends StatefulWidget {
  const TypetestScreen({super.key});

  @override
  State<TypetestScreen> createState() => _TypetestScreenState();
}

class _TypetestScreenState extends State<TypetestScreen> {
  int _type = 0; // 타입 점수, 작을수록 내향형, 클수록 외향형
  final PageController _pageController = PageController(); // 페이지 전환을 위한 컨트롤러
  int _currentQuestionIndex = 0; // 현재 질문 인덱스
  int count = 1; // 질문 번호 카운터
  double progress = 0; // 진행 상태 (0.0 - 1.0)

  final List<String> _questions = [
    // 질문 목록
    "아무도 없는 낯선 행성에 나혼자 있다는 것을 알게 된 당신! 이때 내가 하는 생각은?",
    "나홀로인 줄 알았던 행성에서 외계인을 만났다! 외계인이 나를 쳐다보고 있는데...",
    "외계인이랑 어찌저찌 친구가 되었다. 그런데 외계인이 우울해서 옆 행성을 침략을 하겠다고 한다.",
    "나와 외계인은 함께 옆 행성을 침략하기로 한다.",
    "우주선이 고장 나서 돌아갈 방법이 없다면?",
    "행성에서 신기한 생명체를 발견했다! 어떻게 할까?"
  ];

  final List<String> _outgoingAnswer = [
    // 외향적인 답변 목록
    "이렇게 된 이상 혼자 모험을 떠나보자!",
    "안녕? 우리 친구할래? 다가간다",
    "오, 재밌을 것 같은데? 나도 도와줄게!",
    "쳐들어가자",
    "수리할 방법을 찾아서 해결해보자!",
    "바로 다가가서 말을 걸어본다!"
  ];

  final List<String> _reservedAnswer = [
    // 내향적인 답변 목록
    "너무 무서워ㅜㅜ 가족들은 어디있을까?",
    "별로 말 걸고 싶지 않아... 눈을 돌려야겠다",
    "왜 우울한데? 내가 들어줄게",
    "안전하게 끝낼 수 있을까? 계획부터 세워야 해.",
    "어쩌지? 너무 걱정돼... 천천히 생각해야겠다.",
    "먼저 조심스럽게 관찰해봐야겠다."
  ];

  String chooseCharacter() {
    List<String> characters = ['오징어', '래서판다', '고양이', '코알라', '올빼미', '고슴도치'];
    if (_type >= 4) {
      return characters[0];
    }
    if (_type >= 2) {
      return characters[1];
    }
    if (_type >= 0) {
      return characters[2];
    }
    if (_type >= -2) {
      return characters[3];
    }
    if (_type >= -4) {
      return characters[4];
    } else {
      return characters[5];
    }
  }

  // 외향적인 답변을 선택했을 때 호출되는 함수
  void _outgoingNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _type += 1; // 외향형 점수 증가
        count += 1; // 질문 번호 증가
        _currentQuestionIndex++; // 다음 질문으로 이동
        progress += 1 / _questions.length; // 진행률 업데이트
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    } else {
      var character = chooseCharacter();
      // 모든 질문이 끝나면 결과 분석 화면으로 이동
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AnalyzingResultsScreen(character: character)));
    }
  }

  // 내향적인 답변을 선택했을 때 호출되는 함수
  void _reservedNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _type -= 1; // 내향형 점수 증가
        count += 1; // 질문 번호 증가
        _currentQuestionIndex++; // 다음 질문으로 이동
        progress += 1 / _questions.length; // 진행률 업데이트
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    } else {
      var character = chooseCharacter();
      // 모든 질문이 끝나면 결과 분석 화면으로 이동
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AnalyzingResultsScreen(
              character: character,
            ),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 너비와 높이를 가져옵니다.
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        //didPop == true , 뒤로가기 제스쳐가 감지되면 호출 된다.
        if (didPop) {
          print('didPop호출');
          return;
        }
        showAppExitDialog(context);
      },
      child: Scaffold(
        backgroundColor: lightpurpleColor, // 배경색 설정
        body: Center(
          child: Container(
            width: screenWidth * 0.9,
            height: screenHeight * 0.8,
            decoration: BoxDecoration(
              color: Colors.white, // 컨테이너 배경색
              borderRadius: BorderRadius.circular(25), // 둥근 모서리 설정
            ),
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.01, // 위쪽 여백
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // 좌우 끝에 배치
                    children: [
                      Text(
                        "Q$count", // 현재 질문 번호 표시
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Image.asset(
                        'assets/images/test_roket_logo.png', // 로켓 이미지
                        scale: 0.5,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: LinearProgressIndicator(
                    value: progress, // 진행률을 설정 (0.0에서 1.0 사이)
                    backgroundColor: Colors.grey[300], // 진행 바의 배경색
                    color: darkpurpleColor, // 진행 바의 색상
                    minHeight: 20, // 진행 바의 높이
                    borderRadius: BorderRadius.circular(20), // 진행 바의 모서리 둥글게 설정
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.08, // 질문과 답변 사이의 여백
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController, // 페이지 전환을 위한 컨트롤러
                    physics:
                        const NeverScrollableScrollPhysics(), // 페이지 스크롤 비활성화
                    itemCount: _questions.length, // 질문 개수
                    itemBuilder: (context, index) {
                      return _buildQuestionPage(index); // 각 질문 페이지 빌드
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 각 질문 페이지를 빌드하는 함수
  Widget _buildQuestionPage(int index) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            _questions[index], // 질문 텍스트
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center, // 텍스트 중앙 정렬
          ),
          SizedBox(height: screenHeight * 0.04),
          ElevatedButton(
            onPressed: _outgoingNextQuestion, // 외향적인 답변을 선택했을 때
            style: ElevatedButton.styleFrom(
                backgroundColor: darkpurpleColor, // 버튼 배경색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // 버튼 모서리 둥글게 설정
                )),
            child: SizedBox(
              width: screenWidth * 0.6,
              height: screenHeight * 0.12,
              child: Center(
                child: Text(
                  _outgoingAnswer[index], // 외향적인 답변 텍스트
                  style: const TextStyle(
                    color: lightpurpleColor, // 텍스트 색상
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: screenHeight * 0.02,
          ),
          ElevatedButton(
            onPressed: _reservedNextQuestion, // 내향적인 답변을 선택했을 때
            style: ElevatedButton.styleFrom(
                backgroundColor: darkpurpleColor, // 버튼 배경색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // 버튼 모서리 둥글게 설정
                )),
            child: SizedBox(
              width: screenWidth * 0.6,
              height: screenHeight * 0.12,
              child: Center(
                child: Text(
                  _reservedAnswer[index], // 내향적인 답변 텍스트
                  style: const TextStyle(
                    color: lightpurpleColor, // 텍스트 색상
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: screenHeight * 0.02,
          )
        ],
      ),
    );
  }
}
