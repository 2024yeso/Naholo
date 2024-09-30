// widgets/map_content.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/review.dart';
import 'dart:async';

class MapContent extends StatelessWidget {
  final Set<Marker> markers;

  final Completer<GoogleMapController> mapController;

  const MapContent({
    super.key,
    required this.markers,
    required this.mapController,
  });

  // 첫 번째 마커의 위도를 가져오는 방법
  CameraPosition _printFirstMarkerLatitude() {
    if (markers.isNotEmpty) {
      Marker firstMarker = markers.first; // 첫 번째 마커에 접근
      double latitude = firstMarker.position.latitude;
      double longitude = firstMarker.position.longitude;

      return CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 14.0, // 필요에 따라 조정
      );
    } else {
      print("마커가 없습니다.");
      return const CameraPosition(
        target: LatLng(37.5665, 126.9780), // 서울의 대략적인 위치
        zoom: 12.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300, // 필요에 따라 조정
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _printFirstMarkerLatitude(),
        onMapCreated: (GoogleMapController controller) {
          mapController.complete(controller);
        },
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
