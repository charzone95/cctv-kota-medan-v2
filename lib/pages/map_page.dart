import 'dart:async';

import 'package:cctv_kota_medan_v2/pages/player_display.dart';
import 'package:cctv_kota_medan_v2/states/camera_state.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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

  GoogleMapController? controller;
  final double _modalHeight = 600.0;
  bool _isModalShown = false;

  @override
  void initState() {
    super.initState();
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

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
              onTap: () async {
                setState(() {
                  _isModalShown = true;
                });
                await showMaterialModalBottomSheet(
                  context: context,
                  builder: (context) => PlayerDisplay(
                    camera: camera,
                    height: _modalHeight,
                  ),
                );

                setState(() {
                  _isModalShown = false;
                });
              },
            );

            markerSet.add(marker);
          }

          return Column(
            children: [
              Expanded(
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(3.585, 98.675),
                    zoom: 16,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    this.controller = controller;

                    _getCurrentPosition().then((position) {
                      controller.moveCamera(CameraUpdate.newLatLng(
                        LatLng(position.latitude, position.longitude),
                      ));
                    });
                  },
                  markers: markerSet,
                  myLocationEnabled: true,
                  padding: const EdgeInsets.all(12.0).copyWith(top: 60.0),
                ),
              ),
              Container(height: _isModalShown ? _modalHeight : 0),
            ],
          );
        },
      ),
    );
  }
}
