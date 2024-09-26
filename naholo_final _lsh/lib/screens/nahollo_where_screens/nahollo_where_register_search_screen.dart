import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
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
  Marker? _searchedPlaceMarker;
  String _address = ""; // 주소를 저장할 변수
  String _placeName = "";
  var _locationData = {
    'name': "장소를 입력하세요",
    'address': "",
  };

  static const String _apiKey =
      'AIzaSyDzTW8RlqkPNcG5xcQJ9HqDnAeQcIfY1xE'; // 실제 API 키를 입력하세요.
  final LatLng _initialPosition =
      const LatLng(37.247605, 127.078443); // 초기 위치 설정

  // 장소 검색 함수
  Future<void> _searchPlace(String query) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$_apiKey&language=ko';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['results'] != null && data['results'].isNotEmpty) {
      final place = data['results'][0];
      final lat = place['geometry']['location']['lat'];
      final lng = place['geometry']['location']['lng'];
      final address = place['formatted_address']; // 주소 정보
      final placeName = place['name'] ?? '이름을 찾을 수 없습니다.';
      print("sfsdfsdf $placeName");
      print(placeName.runtimeType);
      setState(() {
        _searchedPlaceMarker = Marker(
          markerId: const MarkerId('searchedPlace'),
          position: LatLng(lat, lng),
        );
        _address = address; // 주소를 변수에 저장
        _placeName = placeName;
      });

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

  void _registerLocation() {
    if (_searchedPlaceMarker != null) {
      final locationData = {
        'name': _placeName,
        'address': _address,
      };
      _locationData = locationData;
      print("$locationData");
      Navigator.pop(context, _locationData); // 장소 이름과 주소를 리턴
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('등록할 장소를 검색하세요.')),
      );
    }
  }

  // 주소를 가져오는 함수
  /* Future<void> _getAddress(LatLng position) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$_apiKey&language=ko';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['results'] != null && data['results'].isNotEmpty) {
      final address = data['results'][0]['formatted_address'];
      setState(() {
        _searchedPlaceMarker = Marker(
          markerId: const MarkerId('selectedPlace'),
          position: position,
        );
        _address = address; // 주소를 저장
      });
    } else {
      setState(() {
        _address = '주소를 찾을 수 없습니다.';
      });
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        //didPop == true , 뒤로가기 제스쳐가 감지되면 호출 된다.
        if (didPop) {
          return;
        }
        Navigator.pop(context, _locationData);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left), // 원하는 아이콘으로 설정
            onPressed: () {
              Navigator.pop(context, _locationData); // 장소 이름과 주소를 리턴
            },
          ),
          backgroundColor: Colors.white,
          title: const Text(
            '나홀로 어디? 검색',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 1.0), // 세로 패딩 조정
                  hintText: '장소 이름을 입력하세요...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: const Color(0xfff1f2ff),
                ),
                onSubmitted: (value) => _searchPlace(value.trim()),
              ),
            ),
            Expanded(
              child: GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: _initialPosition, zoom: 14.0),
                onMapCreated: (controller) => _mapController = controller,
                mapType: MapType.normal,
                markers:
                    _searchedPlaceMarker != null ? {_searchedPlaceMarker!} : {},
                /*  onTap: (LatLng position) {
                  _getAddress(position); // 지도를 클릭할 때 주소 가져오기
                }, */
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _address == "" ? "장소를 입력해주세요!" : "$_placeName($_address)",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: ElevatedButton(
                onPressed: _registerLocation,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7a4fff),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 35),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.circular(8))),
                child: const Text('이 위치로 등록'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
