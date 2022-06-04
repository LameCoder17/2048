import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:sizer/sizer.dart';
import 'package:twenty_forty_eight/Utils/Colors.dart';
import '../Utils/tile.dart';

// class GameScreen extends StatefulWidget {
//   @override
//   _GameScreenState createState() => _GameScreenState();
// }
//
// class _GameScreenState extends State<GameScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   List<List<Tile>> grid = List.generate(4, (y) => List.generate(4, (x) => Tile(x, y, 0)));
//   Iterable<Tile> get flattenedGrid => grid.expand((e) => e);
//   List<List<Tile>> get cols => List.generate(4, (x) => List.generate(4, (y) => grid[y][x]));
//
//   @override
//   void initState(){
//     super.initState();
//
//     _controller = AnimationController(vsync: this, duration: Duration());
//     grid[1][2].value = 4;
//
//     flattenedGrid.forEach((element) => element.resetAnimations());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     double gridSize = MediaQuery.of(context).size.width - 16.0 * 2;
//     double tileSize = (gridSize - 4.0 * 2) / 4;
//     List<Widget> stackItems = [];
//     stackItems.addAll(flattenedGrid.map((e) => Positioned(
//       left: e.x * tileSize,
//       top: e.y * tileSize,
//       width: tileSize,
//       height: tileSize,
//       child: Center(
//         child: Container(
//           width: tileSize - 4.0 * 2,
//           height: tileSize - 4.0 * 2,
//           decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), color: lightBrown),
//         ),
//       ),
//     )));
//     stackItems.addAll(flattenedGrid.map((e) => AnimatedBuilder(
//         animation: _controller,
//         builder: (context, child) => e.animatedValue.value == 0 ? SizedBox() : Positioned(
//           left: e.x * tileSize,
//           top: e.y * tileSize,
//           width: tileSize,
//           height: tileSize,
//           child: Center(
//             child: Container(
//               width: tileSize - 4.0 * 2,
//               height: tileSize - 4.0 * 2,
//               decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), color: numTileColor[e.animatedValue.value]),
//               child: Center(
//                 child: Text(e.animatedValue.value.toString(),
//                 style: TextStyle(fontSize: 32.0.sp, fontWeight: FontWeight.w600, color: numTextColor[e.animatedValue.value]),),
//               ),
//             ),
//           ),
//         )
//     )));
//
//     return Scaffold(
//       backgroundColor: tan,
//       body: Center(
//         child: Container(
//           width: gridSize,
//           height: gridSize,
//           padding: EdgeInsets.all(4.0),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8.0), color: darkBrown
//           ),
//           child: GestureDetector(
//             onVerticalDragEnd: (details) {
//               if (details.velocity.pixelsPerSecond.dy < -250 && canSwipeUp()) {
//                 // up();
//               } else if (details.velocity.pixelsPerSecond.dy > 250 && canSwipeDown()) {
//                 // down();
//               }
//             },
//             onHorizontalDragEnd: (details) {
//               if (details.velocity.pixelsPerSecond.dx < -1000 && canSwipeLeft()) {
//                 // left();
//               } else if (details.velocity.pixelsPerSecond.dx > 1000 && canSwipeDown()) {
//                 // right();
//               }
//             },
//             child: Stack(
//               children: stackItems,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   bool canSwipeLeft() => grid.any(canSwipe);
//   bool canSwipeRight() => grid.map((e) => e.reversed.toList()).any(canSwipe);
//   bool canSwipeUp() => cols.any(canSwipe);
//   bool canSwipeDown() => cols.map((e) => e.reversed.toList()).any(canSwipe);
//
//   bool canSwipe(List<Tile> tiles){
//     for(int i = 0; i<tiles.length; i++){
//       if(tiles[i].value == 0){
//         if(tiles.skip(i+1).any((element) => element.value != 0)){ return true; }
//       }
//       else{
//         Tile nextNonZero = tiles.skip(i+1).firstWhere((element) => element.value != 0, orElse: () => Tile(0,0,0));
//         if(nextNonZero != Tile(0,0,0) && nextNonZero.value == tiles[i].value){
//           return true;
//         }
//       }
//     }
//     return false;
//   }
//
// }

enum SwipeDirection { up, down, left, right }

class GameState {
  // this is the grid before the swipe has taken place
  final List<List<Tile>> _previousGrid;
  final SwipeDirection swipe;

  GameState(List<List<Tile>> previousGrid, this.swipe) : _previousGrid = previousGrid;

  // always make a copy so mutations don't screw things up.
  List<List> get previousGrid => _previousGrid.map((row) => row.map((tile) => tile.copy()).toList()).toList();
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  List<List<Tile>> grid = List.generate(4, (y) => List.generate(4, (x) => Tile(x, y, 0)));
  List<GameState> gameStates = [];
  List<Tile> toAdd = [];

  Iterable<Tile> get gridTiles => grid.expand((e) => e);
  Iterable<Tile> get allTiles => [gridTiles, toAdd].expand((e) => e);
  List<List<Tile>> get gridCols => List.generate(4, (x) => List.generate(4, (y) => grid[y][x]));

  late Timer aiTimer;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          toAdd.forEach((e) => grid[e.y][e.x].value = e.value);
          gridTiles.forEach((t) => t.resetAnimations());
          toAdd.clear();
        });
      }
    });

    setupNewGame();
  }

  @override
  Widget build(BuildContext context) {
    double contentPadding = 16;
    double borderSize = 4;
    double gridSize = MediaQuery.of(context).size.width - contentPadding * 2;
    double tileSize = (gridSize - borderSize * 2) / 4;
    List<Widget> stackItems = [];
    stackItems.addAll(gridTiles.map((t) => TileWidget(
        x: tileSize * t.x,
        y: tileSize * t.y,
        containerSize: tileSize,
        size: tileSize - borderSize * 2,
        color: lightBrown, child: Container(),)));
    stackItems.addAll(allTiles.map((tile) => AnimatedBuilder(
        animation: controller,
        builder: (context, child) => tile.animatedValue.value == 0
            ? SizedBox()
            : TileWidget(
            x: tileSize * tile.animatedX.value,
            y: tileSize * tile.animatedY.value,
            containerSize: tileSize,
            size: (tileSize - borderSize * 2) * tile.size.value,
            color: numTileColor[tile.animatedValue.value]!,
            child: Center(child: TileNumber(tile.animatedValue.value))))));

    return Scaffold(
        backgroundColor: tan,
        body: Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Swiper(
                  up: () => merge(SwipeDirection.up),
                  down: () => merge(SwipeDirection.down),
                  left: () => merge(SwipeDirection.left),
                  right: () => merge(SwipeDirection.right),
                  child: Container(
                      height: gridSize,
                      width: gridSize,
                      padding: EdgeInsets.all(borderSize),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(cornerRadius), color: darkBrown),
                      child: Stack(
                        children: stackItems,
                      ))),
              BigButton(label: "Undo", color: numColor, onPressed: gameStates.isEmpty ? () => print('Hi') : undoMove),
              BigButton(label: "Restart", color: orange, onPressed: setupNewGame),
            ])));
  }

  void undoMove() {
    GameState previousState = gameStates.removeLast();
    bool Function() mergeFn;
    switch (previousState.swipe) {
      case SwipeDirection.up:
        mergeFn = mergeUp;
        break;
      case SwipeDirection.down:
        mergeFn = mergeDown;
        break;
      case SwipeDirection.left:
        mergeFn = mergeLeft;
        break;
      case SwipeDirection.right:
        mergeFn = mergeRight;
        break;
    }
    setState(() {
      this.grid = previousState.previousGrid as List<List<Tile>>;
      mergeFn();
      controller.reverse(from: .99).then((_) {
        setState(() {
          this.grid = previousState.previousGrid as List<List<Tile>>;
          gridTiles.forEach((t) => t.resetAnimations());
        });
      });
    });
  }

  void merge(SwipeDirection direction) {
    bool Function() mergeFn;
    switch (direction) {
      case SwipeDirection.up:
        mergeFn = mergeUp;
        break;
      case SwipeDirection.down:
        mergeFn = mergeDown;
        break;
      case SwipeDirection.left:
        mergeFn = mergeLeft;
        break;
      case SwipeDirection.right:
        mergeFn = mergeRight;
        break;
    }
    List<List<Tile>>? gridBeforeSwipe = grid.map((row) => row.map((tile) => tile.copy()).toList()).cast<List<Tile>>().toList();
    setState(() {
      if (mergeFn()) {
        gameStates.add(GameState(gridBeforeSwipe, direction));
        addNewTiles([2]);
        controller.forward(from: 0);
      }
    });
  }

  bool mergeLeft() => grid.map((e) => mergeTiles(e)).toList().any((e) => e);

  bool mergeRight() => grid.map((e) => mergeTiles(e.reversed.toList())).toList().any((e) => e);

  bool mergeUp() => gridCols.map((e) => mergeTiles(e)).toList().any((e) => e);

  bool mergeDown() => gridCols.map((e) => mergeTiles(e.reversed.toList())).toList().any((e) => e);

  bool mergeTiles(List<Tile> tiles) {
    bool didChange = false;
    for (int i = 0; i < tiles.length; i++) {
      for (int j = i; j < tiles.length; j++) {
        if (tiles[j].value != 0) {
          Tile mergeTile = tiles.skip(j + 1).firstWhere((t) => t.value != 0, orElse: () => Tile(0,0,0));
          if (mergeTile != Tile(0,0,0) && mergeTile.value != tiles[j].value) {
            mergeTile = Tile(0,0,0);
          }
          if (i != j || mergeTile != Tile(0,0,0)) {
            didChange = true;
            int resultValue = tiles[j].value;
            tiles[j].moveTo(controller, tiles[i].x, tiles[i].y);
            if (mergeTile != Tile(0,0,0)) {
              resultValue += mergeTile.value;
              mergeTile.moveTo(controller, tiles[i].x, tiles[i].y);
              mergeTile.bounce(controller);
              mergeTile.changeNumber(controller, resultValue);
              mergeTile.value = 0;
              tiles[j].changeNumber(controller, 0);
            }
            tiles[j].value = 0;
            tiles[i].value = resultValue;
          }
          break;
        }
      }
    }
    return didChange;
  }

  void addNewTiles(List<int> values) {
    List<Tile> empty = gridTiles.where((t) => t.value == 0).toList();
    empty.shuffle();
    for (int i = 0; i < values.length; i++) {
      toAdd.add(Tile(empty[i].x, empty[i].y, values[i])..appear(controller));
    }
  }

  void setupNewGame() {
    setState(() {
      gameStates.clear();
      gridTiles.forEach((t) {
        t.value = 0;
        t.resetAnimations();
      });
      toAdd.clear();
      addNewTiles([2, 2]);
      controller.forward(from: 0);
    });
  }
}