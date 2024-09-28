// widgets/map_content.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/review.dart';
import 'dart:async';

class MapContent extends StatelessWidget {
  final Set<Marker> markers;
  final CameraPosition initialPosition;
  final Completer<GoogleMapController> mapController;

  MapContent({
    required this.markers,
    required this.initialPosition,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // 필요에 따라 조정
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialPosition,
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
