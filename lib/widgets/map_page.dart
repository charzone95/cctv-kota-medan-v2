import 'dart:async';

import 'package:cctv_kota_medan_v2/states/camera_state.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MapDisplay(),
    );
  }
}

class MapDisplay extends StatefulWidget {
  const MapDisplay({
    super.key,
  });

  @override
  State<MapDisplay> createState() => _MapDisplayState();
}

class _MapDisplayState extends State<MapDisplay> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CameraState>(
        builder: (context, state, child) {
          Set<Marker> markerSet = {};

          for (var camera in state.cameraList) {
            var marker = Marker(
              markerId: MarkerId(camera.id),
              position: LatLng(
                double.parse(camera.lat),
                double.parse(camera.lng),
              ),
            );

            markerSet.add(marker);
          }

          return GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: LatLng(3.585, 98.675),
              zoom: 15.5,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: markerSet,
          );
        },
      ),
    );
  }
}
