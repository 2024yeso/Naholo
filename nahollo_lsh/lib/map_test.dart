import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );

  @override
  void initState() {
    super.initState();
    _checkLocationPermission(); // 위치 권한 확인
  }

  Future<void> _checkLocationPermission() async {
    try {
      Location location = Location();

      // 위치 서비스 사용 가능한지 확인
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          debugPrint("위치 서비스가 비활성화되어 있습니다.");
          return;
        }
      }

      // 위치 권한 상태 확인
      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          debugPrint("위치 권한이 거부되었습니다.");
          return;
        }
      }

      debugPrint("위치 권한이 허용되었습니다.");
      _currentLocation();
    } catch (e) {
      debugPrint("위치 권한 확인 중 오류 발생: $e");
    }
  }

  Future<void> _currentLocation() async {
    try {
      final GoogleMapController controller = await _controller.future;
      Location location = Location();
      final currentLocation = await location.getLocation();

      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: 18.0,
        ),
      ));
      debugPrint("현재 위치로 이동했습니다.");
    } catch (e) {
      debugPrint("현재 위치를 가져오는 중 오류 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          debugPrint("지도 생성 완료");
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _currentLocation,
        label: const Text('현재 위치로 이동'),
        icon: const Icon(Icons.my_location),
      ),
    );
  }
}
