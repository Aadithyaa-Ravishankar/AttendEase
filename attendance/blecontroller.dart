import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  final FlutterBluePlus ble = FlutterBluePlus();
  final RxList<ScanResult> scanResults = <ScanResult>[].obs; // Reactive list

  @override
  void onInit() {
    super.onInit();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location
    ].request();
  }

  Future<void> startScan() async {
    // Request permissions before scanning
    await requestPermissions();

    scanResults.clear(); // Clear previous scan results

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));

    FlutterBluePlus.scanResults.listen((results) {
      scanResults.assignAll(results); // Update observable list
      update();
    });
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }
}
