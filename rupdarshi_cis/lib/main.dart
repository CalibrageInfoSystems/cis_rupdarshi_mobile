import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:rupdarshi_cis/common/Constants.dart';
import 'package:rupdarshi_cis/common/SessionManager.dart';
import 'package:rupdarshi_cis/screens/Home_screen.dart';
import 'package:rupdarshi_cis/screens/NewHomeScreen.dart';
import 'package:rupdarshi_cis/screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
  debug: true // optional: set false to disable printing logs to console
);
  
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Color pickerColor = new Color(0 * 092651);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rupdarshi',
      theme: new ThemeData(
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme.apply(),
        ),
        cursorColor: Constants.appColor,
        primarySwatch: Colors.grey,
        primaryColorDark: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool islogin = false;
  @override
  void initState() {
    SessionManager().getIsLogin().then((value) {
      islogin = value;
      print('is login new splash $islogin');
    });
    super.initState();
    Timer(
        Duration(seconds: 1),
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) =>
                islogin == true ? NewHomeScreen() : LoginPage())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/Logo-splash-screen.png'),
      ),
    );
  }
}
