import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class NaholloWhereRegisterSearchScreen extends StatefulWidget {
  const NaholloWhereRegisterSearchScreen({super.key});

  @override
  State<NaholloWhereRegisterSearchScreen> createState() =>
      _NaholloWhereRegisterSearchScreenState();
}

class _NaholloWhereRegisterSearchScreenState
    extends State<NaholloWhereRegisterSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  static const String _apiKey =
      'AIzaSyDzTW8RlqkPNcG5xcQJ9HqDnAeQcIfY1xE'; // API 키 설정
  final LatLng _initialPosition =
      const LatLng(37.5665, 126.9780); // 서울의 초기 위치 설정

  // 장소 검색 함수
  Future<void> _searchPlace(String query) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$_apiKey';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['results'] != null && data['results'].isNotEmpty) {
      final place = data['results'][0];
      final lat = place['geometry']['location']['lat'];
      final lng = place['geometry']['location']['lng'];

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(lat, lng),
        18.0,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('장소를 찾을 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가게 검색하기'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '가게 이름을 입력하세요...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchPlace(_searchController.text.trim());
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: _initialPosition, zoom: 14.0),
              onMapCreated: (controller) => _mapController = controller,
              mapType: MapType.normal,
            ),
          ),
        ],
      ),
    );
  }
}
