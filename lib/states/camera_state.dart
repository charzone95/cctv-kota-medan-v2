import 'package:cctv_kota_medan_v2/models/camera_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CameraState extends ChangeNotifier {
  final List<CameraModel> _cameraList = [];

  List<CameraModel> get cameraList => _cameraList;

  CameraState() {
    retrieveCameraList();
  }

  retrieveCameraList() async {
    var collection = FirebaseFirestore.instance.collection('cameras');

    var dataSnapshot = await collection.get();

    cameraList.clear();
    for (var doc in dataSnapshot.docs) {
      var model = CameraModel.fromJSON(doc.data());

      cameraList.add(model);
    }

    notifyListeners();
  }
}
