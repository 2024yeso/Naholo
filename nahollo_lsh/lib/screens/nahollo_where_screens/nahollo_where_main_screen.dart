import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nahollo/screens/nahollo_where_screens/nahollo_where_register_screen.dart';
import 'package:nahollo/util.dart';
import 'package:nahollo/widgets/swippingcard_widget.dart';

class NaholloWhereMainScreen extends StatefulWidget {
  const NaholloWhereMainScreen({super.key});

  @override
  State<NaholloWhereMainScreen> createState() => _NaholloWhereMainScreenState();
}

class _NaholloWhereMainScreenState extends State<NaholloWhereMainScreen> {
  final int _selectedIndex = 0; // 선택된 인덱스

  @override
  Widget build(BuildContext context) {
    var size = SizeUtil.getScreenSize(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              SizedBox(
                width: size.width * 0.8,
                height: size.width * 0.15,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onChanged: (value) {
                    // Handle search query
                    print(value);
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal, // 가로로 스크롤 가능하게 설정
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(20, 10),
                      ),
                      child: const Text("전체"),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(20, 10),
                      ),
                      child: const Text("혼놀"),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(20, 10),
                      ),
                      child: const Text("혼밥"),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(20, 10),
                      ),
                      child: const Text("혼박"),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(20, 10),
                      ),
                      child: const Text("혼술"),
                    ),
                  ],
                ),
              ),
              const Row(
                children: [],
              ),
              const Text("전국 핫플 혼놀 장소"),
              ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const NaholloWhereRegisterScreen(),
                      )),
                  child: const Text("글쓰기")),
              CustomBottomNavBar(selectedIndex: _selectedIndex)
            ],
          ),
        ),
      ),
    );
  }
}
