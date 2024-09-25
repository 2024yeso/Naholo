// diary_search.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/sizeScaler.dart'; // 크기 조절

class DiarySearch extends StatelessWidget {
  const DiarySearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Posts'),
      ),
      body: const Center(
        child: Text('Search functionality goes here'),
      ),
    );
  }
}
  