import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:sizer/sizer.dart';
import 'Colors.dart';

List<int> gameScore = [];
int newScore= 0;

class Tile {
  final int x;
  final int y;

  int value;

  late Animation<double> animatedX;
  late Animation<double> animatedY;
  late Animation<double> size;
  late Animation<int> animatedValue;

  Tile(this.x, this.y, this.value) {
    resetAnimations();
  }

  void resetAnimations() {
    animatedX = AlwaysStoppedAnimation(x.toDouble());
    animatedY = AlwaysStoppedAnimation(y.toDouble());
    size = AlwaysStoppedAnimation(1.0);
    animatedValue = AlwaysStoppedAnimation(value);
  }

  void moveTo(Animation<double> parent, int x, int y) {
    Animation<double> curved = CurvedAnimation(parent: parent, curve: Interval(0.0, moveInterval));
    animatedX = Tween(begin: this.x.toDouble(), end: x.toDouble()).animate(curved);
    animatedY = Tween(begin: this.y.toDouble(), end: y.toDouble()).animate(curved);
  }

  void bounce(Animation<double> parent) {
    size = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1.0),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1.0),
    ]).animate(CurvedAnimation(parent: parent, curve: Interval(moveInterval, 1.0)));
  }

  void changeNumber(Animation<double> parent, int newValue) {
    animatedValue = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(value), weight: .01),
      TweenSequenceItem(tween: ConstantTween(newValue), weight: .99),
    ]).animate(CurvedAnimation(parent: parent, curve: Interval(moveInterval, 1.0)));
  }

  void appear(Animation<double> parent) {
    size = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: parent, curve: Interval(moveInterval, 1.0)));
  }

  Tile copy() {
    Tile t = Tile(x, y, value);
    t.resetAnimations();
    return t;
  }
}

class TileWidget extends StatelessWidget {
  final double x;
  final double y;
  final double containerSize;
  final double size;
  final Color color;
  final Widget child;

  const TileWidget({Key? key, required this.x, required this.y, required this.containerSize, required this.size, required this.color, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => Positioned(
      left: x,
      top: y,
      child: Neumorphic(
        style: NeumorphicStyle(
            shape: NeumorphicShape.convex,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
            depth: 8,
            lightSource: LightSource.top,
            color: Colors.grey
        ),
        child: Container(
            width: containerSize,
            height: containerSize,
            child: Center(
                child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(cornerRadius), color: color),
                    child: child))),
      ));
}

class TileNumber extends StatelessWidget {
  final int val;

  const TileNumber(this.val, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => NeumorphicText("$val",
      textStyle: NeumorphicTextStyle(fontSize: val > 512 ? 28.0.sp : 35.0.sp, fontWeight: FontWeight.w900),
      style: NeumorphicStyle(color: numTextColor[val]),
  );
}

class Swiper extends StatelessWidget {
  final Function() up;
  final Function() down;
  final Function() left;
  final Function() right;
  final Widget child;

  const Swiper({Key? key, required this.up, required this.down, required this.left, required this.right, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dy < -250) {
          up();
        } else if (details.velocity.pixelsPerSecond.dy > 250) {
          down();
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx < -1000) {
          left();
        } else if (details.velocity.pixelsPerSecond.dx > 1000) {
          right();
        }
      },
      child: child);
}