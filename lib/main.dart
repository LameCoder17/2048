import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:sizer/sizer.dart';
import 'package:twenty_forty_eight/Screens/gameScreen.dart';
import 'package:twenty_forty_eight/Screens/mainScreen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return NeumorphicApp(
        debugShowCheckedModeBanner: false,
        title: 'Welcome to 2048',
        home: MainScreen(),
      );
    });
  }
}