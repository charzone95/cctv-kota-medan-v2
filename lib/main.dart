import 'package:cctv_kota_medan_v2/firebase_options.dart';
import 'package:cctv_kota_medan_v2/res/strings.dart';
import 'package:cctv_kota_medan_v2/states/camera_state.dart';
import 'package:cctv_kota_medan_v2/widgets/map_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      print("Using local emulator");
    } catch (e) {
      print("Error: $e");
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ChangeNotifierProvider(
        create: (context) => CameraState(),
        child: MapPage(),
      ),
    );
  }
}
