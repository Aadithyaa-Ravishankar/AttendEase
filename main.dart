import 'package:copypaste1/academia/dash.dart';
import 'package:copypaste1/academia/grades.dart';
import 'package:copypaste1/academia/themes.dart';
import 'package:copypaste1/academia/timetable.dart';
import 'package:copypaste1/academia/userscreen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/androidenterprise/v1.dart' as gapis;
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
int selectedindex = 1;

Future<void> requestPermissions() async {
  await Permission.appTrackingTransparency.request();
  await Permission.notification.request();
}

Future<void> signInWithGoogle() async {
  try {
    final success = await supabase.auth.signInWithOAuth(
      Provider.google as OAuthProvider,
      authScreenLaunchMode: LaunchMode.externalApplication, // Opens Google auth in a browser
    );

    if (success) {
      final user = supabase.auth.currentUser;
      print("Google Sign-In Successful: ${user?.email}");
    } else {
      print("Google Sign-In Failed");
    }
  } catch (e) {
    print("Google Sign-In Error: $e");
  }
}
enum Provider {
  google,
  // Add other providers if needed
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize( url: 'https://htesnyiywuwwvhiqqdzq.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0ZXNueWl5d3V3d3ZoaXFxZHpxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxMDQ2ODksImV4cCI6MjA1NTY4MDY4OX0.J1WazXNKrw2xjbGYyP-gmVOEb-evUvMhqyIv4szr9Kg',);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(SecureClassApp());
}

class SecureClassApp extends StatefulWidget {
  const SecureClassApp({super.key});
  @override
  State<SecureClassApp> createState() => _SecureClassAppState();
}

class _SecureClassAppState extends State<SecureClassApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> classes = [
    {'subject': 'Chemistry', 'time': '8:00 - 9:45'},
    {'subject': 'Biology', 'time': '10:00 - 11:45'},
    {'subject': 'Mathematics', 'time': '12:00 - 1:45'},
    {'subject': 'Physics', 'time': '2:00 - 3:45'},
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedindex = index;
    });
  }

  final List Screens = [
    TimetableScreen(),
    Dash(),
    GradesScreen(),
    UserScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        onTap: _onItemTapped,
        index: selectedindex,
        backgroundColor: Color(0xFFFCFCEE),
        color: (themes[0][themecode[no]])?.first ?? Colors.black,
        height: 60,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 500),
        items: [
          Icon(Icons.schedule, color: Colors.white),
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.bar_chart, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
      ),
      backgroundColor: Color(0xFFFCFCEE),
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              size: 30,
              Icons.label,
            ),
          )
        ],
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("𝗔𝗧𝗧𝗘𝗡𝗗𝗘𝗔𝗦𝗘",
              style: TextStyle(
                  fontSize: 33,
                  color: (themes[0][themecode[no]])?.first ?? Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: "serif")),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: Screens[selectedindex],
      ),
    );
  }
}
