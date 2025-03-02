
import 'package:copypaste1/attendance/blecontroller.dart';
import 'package:copypaste1/attendance/classroompage.dart';
import 'package:copypaste1/attendance/container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final String targetMacAddress = "C0:5D:89:B1:2E:86"; // Target MAC Address
  final Map<String, String> classroomDevices = {
    "C0:5D:89:B1:2E:86": "Classroom A"
  }; // Dictionary to assign devices to classrooms

  void checkBiometricAuth() async {
    Biometric biometric = Biometric();

    bool available = await biometric.isBiometricAvailable();
    if (!available) {
      print("Biometric authentication not available.");
      return;
    }

    bool authenticated = await biometric.authenticate();
    if (authenticated) {
      print("Authentication successful!");
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              PreventExitScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1), // Start from bottom
                end: Offset.zero, // End at normal position
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut, // Smooth animation
              )),
              child: PreventExitScreen(),
            );
          },
        ),
      );
    } else {
      print("Authentication failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Classrooms",
          style:
              TextStyle(color: Color.fromARGB(255, 6, 7, 7), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      body: GetBuilder<BleController>(
        init: BleController(),
        builder: (controller) {
          return Column(
            children: [
              const SizedBox(height: 20),
              Obx(() {
                final filteredDevices = controller.scanResults
                    .where((result) => result.device.remoteId.toString() == targetMacAddress)
                    .toList();

                if (filteredDevices.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bluetooth_searching,
                              size: 80, color: Colors.greenAccent),
                          SizedBox(height: 10),
                          Text(
                            "Target device not found",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredDevices.length,
                    itemBuilder: (context, index) {
                      final device = filteredDevices[index].device;
                      final classroomName =
                          classroomDevices[device.remoteId.toString()] ?? "Unknown Classroom";

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: GestureDetector(
                          onTap: () {
                            checkBiometricAuth();
                          },
                          child: NeomorphicContainer(
                            title: device.platformName.isNotEmpty
                                ? device.platformName
                                : "ESP32 Device",
                            subtitle: "$classroomName\n${device.remoteId}",
                            trailing: const Icon(Icons.menu,
                                color: Colors.greenAccent),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.find<BleController>().stopScan();
          Get.find<BleController>().startScan();
        },
        icon: const Icon(
          Icons.bluetooth_searching,
          color: Colors.black,
        ),
        label: const Text(
          "Scan",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.greenAccent,
      ),
    );
  }
}

class Biometric {
  final LocalAuthentication auth = LocalAuthentication();

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      print("Error checking biometrics: $e");
      return false; // Return false instead of null
    }
  }

  /// Perform biometric authentication
  Future<bool> authenticate() async {
    try {
      return await auth.authenticate(
        localizedReason: "Authenticate to join class",
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      print("Authentication failed: $e");
      return false;
    }
  }
}
