import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PreventExitScreen extends StatefulWidget {
  const PreventExitScreen({super.key});

  @override
  _PreventExitScreenState createState() => _PreventExitScreenState();
}

class _PreventExitScreenState extends State<PreventExitScreen>
    with WidgetsBindingObserver {
  bool _canExit = false;
  int _timeLeft = 60;
  late Timer _timer;
  bool _isOutOfApp = false;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _startExitTimer();
    _setFullScreenMode();
    _initNotifications();
    WidgetsBinding.instance.addObserver(this);
  }

  void _setFullScreenMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _startExitTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _canExit = true;
        _exitScreen();
      }
    });
  }

  void _exitScreen() {
    _timer.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Navigator.pop(context);
  }

  void _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(settings);
  }

  Future<void> _showImmediateWarningNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'warning_channel',
      'Warning Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      fullScreenIntent: true,
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(0, "Warning!",
        "Return immediately or you'll be marked absent!", details);
  }

  void _markAbsent(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "You have been marked absent!",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    print("User marked absent.");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _isOutOfApp = true;
      _showImmediateWarningNotification(); // Immediate notification
      Timer(const Duration(seconds: 30), () {
        if (_isOutOfApp) {
          _markAbsent(context);
        }
      });
    } else if (state == AppLifecycleState.resumed) {
      _isOutOfApp = false;
      _notificationsPlugin.cancel(0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "You are back in the app!",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.greenAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _canExit,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              SizedBox(
                width: 35,
                height: 35,
                child: CircularProgressIndicator(
                  value: 1 - (_timeLeft / 60),
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.shade800,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                ),
              ),
              const SizedBox(width: 12),
              Text("$_timeLeft",
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent)),
            ],
          ),
        ),
        body: Center(
          child: Text(
            _canExit ? "You can now exit." : "Please wait...",
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _notificationsPlugin.cancel(0);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
