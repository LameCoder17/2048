import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:sizer/sizer.dart';
import 'package:twenty_forty_eight/Screens/gameScreen.dart';
import 'package:twenty_forty_eight/Utils/Colors.dart';
import '../Utils/tile.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tan,
      body: Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.0.sp),
              child: NeumorphicText(
                '2048 - The Game',
                style: NeumorphicStyle(color: greyText),
                textStyle: NeumorphicTextStyle(fontSize: 36.0.sp),
              ),
            ),
            Container(
              width: 60.w,
              margin: EdgeInsets.symmetric(vertical: 10.0.sp),
              child: NeumorphicButton(
                child: Text('Start Game', style: TextStyle(color: Colors.white, fontSize: 20.0.sp), textAlign: TextAlign.center,),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen()),
                ),
                style: NeumorphicStyle(
                  color: orange,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(cornerRadius)),
                ),
              ),
            ),
            Container(
              width: 60.w,
              margin: EdgeInsets.symmetric(vertical: 10.0.sp),
              child: NeumorphicButton(
                child: Text('Settings', style: TextStyle(color: Colors.white, fontSize: 20.0.sp), textAlign: TextAlign.center,),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen()),
                ),
                style: NeumorphicStyle(
                  color: orange,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(cornerRadius)),
                ),
              ),
            ),
            Container(
              width: 60.w,
              margin: EdgeInsets.symmetric(vertical: 10.0.sp),
              child: NeumorphicButton(
                child: Text('Exit', style: TextStyle(color: Colors.white, fontSize: 20.0.sp), textAlign: TextAlign.center,),
                onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                style: NeumorphicStyle(
                  color: orange,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(cornerRadius)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}