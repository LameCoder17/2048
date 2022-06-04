import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:twenty_forty_eight/Screens/gameScreen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Welcome to Flutter',
        home: GameScreen(),
      );
    });
  }
}