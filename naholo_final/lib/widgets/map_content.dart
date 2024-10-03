import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapContent extends StatefulWidget {
  final Set<Marker> markers;
  final Completer<GoogleMapController> mapController;

  const MapContent({
    super.key,
    required this.markers,
    required this.mapController,
  });

  @override
  _MapContentState createState() => _MapContentState();
}

class _MapContentState extends State<MapContent> {
  BitmapDescriptor? customIcon; // 커스텀 마커 아이콘

  @override
  void initState() {
    super.initState();
    _loadCustomMarker(); // 커스텀 마커 로드
  }

  // 커스텀 마커를 로드하는 함수
  Future<void> _loadCustomMarker() async {
    BitmapDescriptor bitmap = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(30, 39)), // 이미지 크기 설정
      'assets/images/review_marker.png', // PNG 파일 경로
    );
    setState(() {
      customIcon = bitmap; // 커스텀 마커 아이콘 설정
    });
  }

  // 첫 위치를 반환하는 함수 (마커의 첫 위치 또는 기본 위치)
  CameraPosition _getInitialCameraPosition() {
    /*  if (widget.markers.isNotEmpty) {
      Marker firstMarker = widget.markers.first;
      return CameraPosition(
        target: LatLng(
            firstMarker.position.latitude, firstMarker.position.longitude),
        zoom: 10.0, // 줌 레벨 설정
      );
    } else {
      return const CameraPosition(
        target: LatLng(37.5665, 126.9780), // 서울의 대략적인 위치
        zoom: 12.0,
      );
    }  */

    // 경희대학교 국제캠퍼스 위치로 설정
    return const CameraPosition(
      target: LatLng(37.242566, 127.080692), // 경희대학교 국제캠퍼스 위치
      zoom: 10.0,
    );
  }

  // 마커를 커스텀 아이콘으로 추가하는 함수 (중복된 위치는 하나만 표시)
  Set<Marker> _createCustomMarkers() {
    // 중복된 위치를 추적할 Set
    Set<LatLng> uniquePositions = {};

    return widget.markers.where((marker) {
      // 위치가 중복되지 않으면 true를 반환하여 필터링
      if (uniquePositions.contains(marker.position)) {
        return false; // 이미 위치가 추가되었으면 마커를 제외
      } else {
        uniquePositions.add(marker.position); // 새로운 위치는 Set에 추가
        return true; // 위치가 중복되지 않으면 마커 포함
      }
    }).map((marker) {
      return Marker(
        markerId: marker.markerId,
        position: marker.position,
        icon: customIcon ?? BitmapDescriptor.defaultMarker, // 커스텀 아이콘 적용
        infoWindow: marker.infoWindow,
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _getInitialCameraPosition(),
        onMapCreated: (GoogleMapController controller) {
          widget.mapController.complete(controller);
        },
        markers: _createCustomMarkers(), // 커스텀 마커 적용
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
