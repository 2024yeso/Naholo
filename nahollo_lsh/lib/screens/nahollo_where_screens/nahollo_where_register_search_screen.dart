import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NaholloWhereRegisterSearchScreen extends StatefulWidget {
  const NaholloWhereRegisterSearchScreen({super.key});

  @override
  State<NaholloWhereRegisterSearchScreen> createState() =>
      _NaholloWhereRegisterSearchScreenState();
}

class _NaholloWhereRegisterSearchScreenState
    extends State<NaholloWhereRegisterSearchScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>(); // Google Map 컨트롤러 관리

  LocationData? _currentPosition;
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _locationPermission();
  }

  // 위치 권한을 요청하고 현재 위치를 가져오는 메서드
  Future<void> _locationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // 위치 서비스 활성화 확인
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // 위치 권한 확인
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // 현재 위치 가져오기
    _currentPosition = await _location.getLocation();
    setState(() {});
  }

  // 현재 위치로 이동하는 메서드
  void _currentLocation() async {
    if (_currentPosition != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
                _currentPosition!.latitude!, _currentPosition!.longitude!),
            zoom: 18.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentPosition?.latitude ?? 37.50508097213444,
            _currentPosition?.longitude ?? 126.95493073306663,
          ),
          zoom: 18,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller); // 맵이 생성되면 컨트롤러를 완료합니다.
        },
        myLocationEnabled: true, // 현재 위치 표시 활성화
        myLocationButtonEnabled: true, // 현재 위치로 이동하는 버튼 활성화
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _currentLocation, // 현재 위치로 이동하는 버튼
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
