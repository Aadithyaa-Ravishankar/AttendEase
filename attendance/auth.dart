import 'package:local_auth/local_auth.dart';

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
      return false; // Ensure a valid boolean return
    }
  }
}
