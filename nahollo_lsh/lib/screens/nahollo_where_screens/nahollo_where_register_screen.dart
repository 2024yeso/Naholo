import 'package:flutter/material.dart';
import 'package:nahollo/screens/nahollo_where_screens/nahollo_where_register_search_screen.dart';
import 'package:nahollo/util.dart';

class NaholloWhereRegisterScreen extends StatefulWidget {
  const NaholloWhereRegisterScreen({super.key});

  @override
  State<NaholloWhereRegisterScreen> createState() =>
      _NaholloWhereRegisterScreenState();
}

class _NaholloWhereRegisterScreenState
    extends State<NaholloWhereRegisterScreen> {
  @override
  Widget build(BuildContext context) {
    var size = SizeUtil.getScreenSize(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const NaholloWhereRegisterSearchScreen(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                width: size.width * 0.8,
                height: size.width * 0.2,
                child: const Text("장소를 검색해주세요"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
