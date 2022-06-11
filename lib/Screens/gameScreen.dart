import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:sizer/sizer.dart';
import 'package:twenty_forty_eight/Utils/Colors.dart';
import '../Utils/tile.dart';

enum SwipeDirection { up, down, left, right }

class GameState {
  final List<List<Tile>> _previousGrid;
  final SwipeDirection swipe;

  GameState(List<List<Tile>> previousGrid, this.swipe) : _previousGrid = previousGrid;

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
    double contentPadding = 16.0.sp;
    double borderSize = 4.0.sp;
    double gridSize = 100.w - contentPadding * 2;
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
            child: Center(child: FittedBox(child: TileNumber(tile.animatedValue.value)))))));

    return Scaffold(
        appBar: NeumorphicAppBar(
          centerTitle: true,
          title: NeumorphicText(
            gameScore.last.toString(),
            textStyle: NeumorphicTextStyle(fontSize: 24.0.sp),
            style: NeumorphicStyle(color: orange),
          ),
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Neumorphic(
              style: NeumorphicStyle(color: orange),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    shape: BoxShape.circle
                ),
                child: NeumorphicIcon(Icons.arrow_back_ios_new_outlined, size: 22.0.sp,),
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: setupNewGame,
              child: Neumorphic(
                style: NeumorphicStyle(color: orange),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle
                  ),
                  child: NeumorphicIcon(Icons.restart_alt_outlined, size: 22.0.sp,),
                ),
              ),
            )
          ],
        ),
        floatingActionButton: GestureDetector(
          onTap: gameStates.isEmpty ? () => setupNewGame : undoMove,
          child: Neumorphic(
            style: NeumorphicStyle(color: orange),
            child: Container(
              height: 7.h,
              width: 7.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  shape: BoxShape.circle
              ),
              child: NeumorphicIcon(Icons.undo_outlined, size: 22.0.sp,),
            ),
          ),
        ),
        backgroundColor: tan,
        body: Container(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Swiper(
                      up: () => merge(SwipeDirection.up),
                      down: () => merge(SwipeDirection.down),
                      left: () => merge(SwipeDirection.left),
                      right: () => merge(SwipeDirection.right),
                      child: Neumorphic(
                        style: NeumorphicStyle(
                            shape: NeumorphicShape.convex,
                            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                            depth: 8,
                            lightSource: LightSource.topLeft,
                            color: Colors.grey
                        ),
                        child: Container(
                            height: gridSize,
                            width: gridSize,
                            padding: EdgeInsets.all(borderSize),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(cornerRadius), color: darkBrown),
                            child: Stack(
                              children: stackItems,
                            )),
                      )),
            ])));
  }

  void undoMove() {
    GameState previousState = gameStates.removeLast();
    gameScore.removeLast();
    bool Function({bool undo}) mergeFn;
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
      mergeFn(undo: true);
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
        gameScore.add(newScore);
        controller.forward(from: 0);
      }
    });
  }

  bool mergeLeft({bool undo = false}) => grid.map((e) => mergeTiles(e, undo: undo)).toList().any((e) => e);

  bool mergeRight({bool undo = false}) => grid.map((e) => mergeTiles(e.reversed.toList(), undo: undo)).toList().any((e) => e);

  bool mergeUp({bool undo = false}) => gridCols.map((e) => mergeTiles(e, undo: undo)).toList().any((e) => e);

  bool mergeDown({bool undo = false}) => gridCols.map((e) => mergeTiles(e.reversed.toList(), undo: undo)).toList().any((e) => e);

  bool mergeTiles(List<Tile> tiles, {bool undo = false}) {
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
              if(mergeTile.value != 0 && !undo){
                newScore = gameScore.last + resultValue;
              }
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
      gameScore.clear();
      gameScore.add(0);
    });
  }
}