import 'package:flutter/material.dart';

import 'package:nahollo/colors.dart';
import 'package:nahollo/screens/type_result_screens/character_creating_screen.dart';
import 'package:nahollo/sizeScaler.dart';
import 'package:nahollo/util.dart';
import 'package:o3d/o3d.dart';
import 'package:nahollo/services/auth_service.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CharacterExplainScreen extends StatefulWidget {
  String character;

  CharacterExplainScreen({super.key, required this.character});

  @override
  State<CharacterExplainScreen> createState() => _CharacterExplainScreenState();
}

class _CharacterExplainScreenState extends State<CharacterExplainScreen> {
  final O3DController controller = O3DController(); // 3D 모델 컨트롤러

  void changeCharacter() {
    String character = widget.character;
    if (character == "래서판다") {
      setState(() {
        widget.character = "red_panda";
      });
    }
    if (character == "오징어") {
      setState(() {
        widget.character = "squid";
      });
    }
    if (character == "고양이") {
      setState(() {
        widget.character = "cat";
      });
    }
    if (character == "코알라") {
      setState(() {
        widget.character = "koala";
      });
    }
    if (character == "올빼미") {
      setState(() {
        widget.character = "owl";
      });
    } else {
      //고슴도치
      setState(() {
        widget.character = "hedgehog";
      });
    }
  }

  String getKoreanCharacterName(String character) {
    if (character == "red_panda") {
      return "래서판다";
    } else if (character == "squid") {
      return "오징어";
    } else if (character == "cat") {
      return "고양이";
    } else if (character == "koala") {
      return "코알라";
    } else if (character == "owl") {
      return "올빼미";
    } else {
      // hedgehog
      return "고슴도치";
    }
  }

  Color getCharacterColor(String character) {
    if (character == "red_panda") {
      return const Color(0xfff6841b); // 주황
    } else if (character == "squid") {
      return const Color(0xff6a35ad); // 보라
    } else if (character == "cat") {
      return const Color(0xffe89e9e); // 핑크
    } else if (character == "koala") {
      return const Color(0xff8c8c8c); // 회색
    } else if (character == "owl") {
      return const Color(0xff683f19); // 갈색
    } else {
      // hedgehog
      return const Color(0xffa68614); // 금색
    }
  }

  String getKoreanSaid(String character) {
    if (character == "red_panda") {
      return "혼자 노는 것도 잘하고\n같이 노는 것도 좋아";
    } else if (character == "squid") {
      return "혼자있는 게 좋지만 가끔 외로워";
    } else if (character == "cat") {
      return "다꺼져 말걸지마";
    } else if (character == "koala") {
      return "모든 게 귀찮아! 그냥 나혼자 할래";
    } else if (character == "owl") {
      return "고독을 즐긴다";
    } else {
      return "혼자가 좋지만\n사실은 같이 노는 것도 좋아";
    }
  }

  Widget characterExplain(String character) {
    Color textColor = const Color(0xff483d70); // 모든 텍스트의 색상
    double fontSize = SizeScaler.scaleSize(context, 9); // 모든 텍스트의 폰트 크기
    FontWeight fontWeight = FontWeight.w400; // 텍스트의 굵기

    if (character == "cat") {
      return Padding(
        padding:
            EdgeInsets.symmetric(horizontal: SizeScaler.scaleSize(context, 8)),
        child: Column(
          children: [
            Text(
              "• 고양이는 독립적인 성향이 강한 동물로, 혼자 사는 생활방식과 잘 맞는 동물이에요. 집에서 기르는 고양이 역시 혼자 있는 시간을 즐기며, 인간의 지속적인 관심이나 보호가 없어도 스트레스를 받지 않는답니다.",
              style: TextStyle(
                  color: textColor, fontSize: fontSize, fontWeight: fontWeight),
            ),
            SizedBox(height: SizeScaler.scaleSize(context, 5)),
            Text(
              "• 고양이는 혼자 놀거나 조용히 주위를 관찰하는 시간이 많아요. 고양이는 정기적으로 먹이를 제공받고, 필요한 환경만 갖추어지면 외로움을 덜 느끼는 동물이에요.",
              style: TextStyle(
                  color: textColor, fontSize: fontSize, fontWeight: fontWeight),
            ),
            SizedBox(height: SizeScaler.scaleSize(context, 5)),
            Text(
              "• 하지만 고양이는 혼자 있는 것을 좋아하면서도 주인과의 유대감을 무시하지 않아요. 혼자 사는 사람들이 가끔은 외로움을 느낄 때, 고양이는 짧은 시간 동안의 교감을 통해 서로에게 안정감을 줄 수 있어요!",
              style: TextStyle(
                  color: textColor, fontSize: fontSize, fontWeight: fontWeight),
            ),
          ],
        ),
      );
    } else if (character == "hedgehog") {
      return Column(
        children: [
          Text(
            "• 고슴도치는 위험을 감지하면 몸을 둥글게 말아 가시를 세우고, 이를 통해 천적들이 쉽게 접근하지 못하게 해요! 가시는 단단하지만 독성은 없으며, 주로 자기를 방어하는 데 사용된답니다.",
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight),
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 5)),
          Text(
            "• 고슴도치는 야행성 동물로, 주로 밤에 활동하며 먹이를 찾아요. 그들의 주된 먹이는 곤충, 달팽이, 지렁이, 과일 등으로, 매우 다양한 식성을 가지고 있어요!",
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight),
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 5)),
          Text(
            "• 그들은 온화한 성격을 지니고 있으며, 천적이 없을 때는 느긋하게 행동하는 경우가 많아요. 고슴도치는 오랫동안 인간에게 귀여운 외모로 사랑받아 왔으며, 최근에는 애완동물로도 인기를 얻고 있답니다. ><",
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight),
          ),
        ],
      );
    } else if (character == "owl") {
      return Column(
        children: [
          Text(
            "• 올빼미는 야행성 맹금류로, 주로 밤에 활동하며 낮에는 휴식을 취하는 독특한 생활 방식을 가지고 있어요. 이들은 놀라운 시력과 청각을 통해 어둠 속에서도 먹이를 찾아내는 능력이 뛰어나요.",
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight),
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 5)),
          Text(
            "• 넓은 시야각을 확보해 주변을 경계하며 먹이를 추적할 수 있어요. 또한, 그들의 귀는 비대칭으로 배치되어 있어 소리가 나는 방향을 정확히 파악할 수 있어요! 감각이 예민한 동물이에요.",
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight),
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 5)),
          Text(
            "• 환경 변화에도 잘 적응하는 강한 생존력을 가지고 있어요. 올빼미는 고대부터 지혜와 신비로움의 상징으로 여겨졌으며, 인간 문화에서도 자주 등장하는 동물이랍니다~",
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight),
          ),
        ],
      );
    } else if (character == "koala") {
      return Column(
        children: [
          Text(
            "• 코알라는 주로 혼자 생활하는 동물이에요. 코알라는 유칼립투스 잎만 먹는데, 이 잎은 영양분이 적고 소화가 어려워 에너지를 많이 쓰지 않기 위해 혼자 조용히 있는 것을 선호해요.",
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight),
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 5)),
          Text(
            "• 코알라는 자신만의 영역을 가지고 살아가요. 각 코알라는 몇 그루의 나무를 차지하며 다른 코알라와 마주치는 걸 피해요. 이들은 영역을 지키기 위해 나무에 향을 남기거나 소리로 신호를 보내요. 이렇게 혼자 있으면 경쟁 없이 충분한 먹이를 얻을 수 있답니다.",
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight),
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 5)),
          Text(
            "• 다만 번식기에는 잠시 다른 코알라와 상호작용할 수 있어요. 수컷은 암컷을 찾기 위해 영역을 넘나들며 교미 활동을 하지만, 번식기가 끝나면 다시 혼자 있는 생활로 돌아간답니다.",
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight),
          ),
        ],
      );
    } else if (character == "squid") {
      return Column(
        children: [
          Text(
            "• 오징어는 주로 혼자 사냥을 하는 독립적인 해양 동물이에요. 그들은 몸의 색을 바꾸거나 먹물을 뿜어내어 포식자들로부터 자신을 보호하고, 사냥할 때도 민첩하게 움직여 먹이를 쉽게 포획할 수 있어요.",
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight),
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 5)),
          Text(
            "• 오징어는 매우 빠른 속도로 물속을 이동할 수 있으며, 물을 제트처럼 내뿜어 추진력을 얻어요. 이 독특한 이동 방식은 포식자를 피하거나 먹이를 추적하는 데 유용하답니다!.",
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight),
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 5)),
          Text(
            "• 일부 오징어 종은 군집 생활을 하기도 하지만, 많은 오징어는 번식과 사냥을 할 때는 혼자서 행동해요. 이들은 짝짓기 후에 많은 알을 낳고, 새끼들은 태어난 후 바로 독립적인 삶을 시작해요.",
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Text(
            "• 래서판다는 고산 지대의 숲에서 주로 나무 위에서 생활하며, 혼자서 먹이를 찾고 자신만의 영역을 지켜요. 혼자 있는 것이 자원을 독점하고 에너지를 절약하는 데 유리하기 때문에 다른 개체와 자주 어울리지 않아요.",
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight),
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 5)),
          Text(
            "• 래서판다는 각자의 영역을 가지고, 서로의 영역에 침범하지 않도록 행동해요. 이들은 냄새를 이용해 자신의 영역을 표시하며, 나무나 바위에 향을 묻히는 방식으로 경계를 표시해요.",
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight),
          ),
          SizedBox(height: SizeScaler.scaleSize(context, 5)),
          Text(
            "• 번식이 끝난 후 암컷은 홀로 새끼를 기르며, 새끼가 어느 정도 자랄 때까지는 독립 생활을 하지 않지만, 이후에는 다시 고독한 생활을 시작해요.",
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight),
          ),
        ],
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.character);
    changeCharacter();
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
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('assets/images/explain_bg.png'),
                fit: BoxFit.cover,
              )),
            ),
            SingleChildScrollView(
              // 화면이 길어질 때 스크롤 가능하게 설정
              child: Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 50, horizontal: 13), // 위아래 패딩 설정
                      child: Container(
                        width: 350,
                        height: 1090, // 컨테이너 높이 설정
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6), // 컨테이너 배경색
                          borderRadius: BorderRadius.circular(20), // 둥근 모서리 설정
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0), // 내부 패딩 설정
                          child: Column(
                            children: [
                              Text(
                                textAlign: TextAlign.center, // 텍스트 중앙 정렬
                                getKoreanSaid(widget.character), // 상단 텍스트
                                style: const TextStyle(
                                  color: darkpurpleColor, // 텍스트 색상
                                  fontSize: 20, // 텍스트 크기
                                  fontWeight: FontWeight.w600, // 텍스트 두께
                                ),
                              ),
                              Text(
                                getKoreanCharacterName(
                                    widget.character), // 캐릭터 이름
                                style: TextStyle(
                                  color: getCharacterColor(
                                      widget.character), // 캐릭터 이름 색상
                                  fontSize: SizeScaler.scaleSize(
                                      context, 20), // 캐릭터 이름 크기
                                  fontWeight: FontWeight.w600, // 캐릭터 이름 두께
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.all(4), // 3D 모델 주변 패딩 설정
                                width: 300,
                                height: 300,
                                child: Card(
                                  color: Colors.transparent, // 카드 배경 투명
                                  elevation: 0, // 그림자 효과 제거
                                  child: O3D(
                                    disableTap: true, // 탭 동작 비활성화
                                    disableZoom: true, // 줌 동작 비활성화
                                    //cameraOrbit: CameraOrbit(1.2, 1, 4), 하면 커짐
                                    // cameraTarget: CameraTarget(20, 20, 5), 하면 작아짐
                                    controller: controller, // 3D 모델 컨트롤러 사용
                                    autoPlay: true, // 자동 재생 설정
                                    src:
                                        "assets/glbs/${widget.character}.glb", // 3D 모델 파일 경로
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  textAlign: TextAlign.start, // 텍스트 중앙 정렬
                                  "특징", // 특징 섹션 제목
                                  style: TextStyle(
                                      color: darkpurpleColor, // 텍스트 색상
                                      fontSize: 20, // 텍스트 크기
                                      fontWeight: FontWeight.w600), // 텍스트 두께
                                ),
                              ),
                              characterExplain(widget.character),
                              SizedBox(
                                height: screenWidth * 0.1, // 텍스트와 버튼 사이의 여백
                              ),
                              Container(
                                width: SizeScaler.scaleSize(context, 151),
                                height: SizeScaler.scaleSize(context, 30),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xff2D7FF6),
                                        Color(0xff7732C2)
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    )),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final authService = AuthService();
                                    final userProvider =
                                        Provider.of<UserProvider>(context,
                                            listen: false);
                                    final user = userProvider.user!;
                                    // 비동기 함수 호출을 위해 onPressed 콜백을 async로 선언
                                    await authService.updateUser(
                                      context: context, // 필수 매개변수로 context 전달
                                      userId: user.userId,
                                      userCharacter: widget
                                          .character, // 예시로 userCharacter를 widget에서 가져옴
                                      // 필요한 다른 필드들을 추가로 전달합니다.
                                    );

                                    // updateUser 함수가 성공적으로 실행된 후 화면 전환
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CharacterCreatingScreen(
                                                character: widget.character),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent, // 버튼 배경색
                                  ),
                                  child: SizedBox(
                                    child: Center(
                                      child: Text(
                                        "캐릭터로 지정하기", // 버튼 텍스트
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: SizeScaler.scaleSize(
                                                context, 9)), // 텍스트 색상과 크기
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.02, // 버튼 사이의 여백
                              ),
                              SizedBox(
                                width: SizeScaler.scaleSize(context, 151),
                                height: SizeScaler.scaleSize(context, 30),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFf1f1f1), // 버튼 배경색
                                  ),
                                  child: SizedBox(
                                    width: screenWidth * 0.5,
                                    height: screenWidth * 0.1,
                                    child: Center(
                                      child: Text(
                                        "테스트 공유하기", // 버튼 텍스트
                                        style: TextStyle(
                                            color: darkpurpleColor,
                                            fontSize: SizeScaler.scaleSize(
                                                context, 9)), // 텍스트 색상과 크기
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
