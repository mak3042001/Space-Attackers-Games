import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:space_attackers/asteroidModel.dart';
import 'package:space_attackers/collisionData.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  double shipX = 0.0, shipY = 0.0;
  double maxHeight = 0.0;
  double initialPosition = 0.0;
  double time = 0.0;
  double velocity = 2.9;
  double gravity = -4.9;
  bool isGameStart = false;
  int score = 0;
  GlobalKey shipGlobalKey = GlobalKey();
  List<GlobalKey> globalKeys = [];
  List<AsteroidModel> asteroidData = [];

  List<AsteroidModel> setAsteroidData() {
    List<AsteroidModel> data = [
      AsteroidModel(const Size(70, 70), const Alignment(3.9, 0.7)),
      AsteroidModel(const Size(100, 100), const Alignment(1.8, -0.5)),
      AsteroidModel(const Size(40, 40), const Alignment(3, -0.3)),
      AsteroidModel(const Size(60, 60), const Alignment(2.3, 0.5)),
    ];
    return data;
  }

  void initGlobalKeys() {
    for (int i = 0; i < 4; i++) {
      globalKeys.add(GlobalKey());
    }
  }

  void startGame() {
    restData();
    isGameStart = true;
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      time = time + 0.02;
      setState(
        () {
          maxHeight = velocity * time + gravity * time * time;
          shipY = initialPosition - maxHeight;
          if (isShipColided()) {
            timer.cancel();
            isGameStart = false;
          }
        },
      );
      moveAsteroid();
    });
  }

  void onJump() {
    setState(() {
      time = 0;
      initialPosition = shipY;
    });
  }

  double generateRandomNumber() {
    Random rand = Random();
    double random = rand.nextDouble() * (-1.0 - 1.0) + 1.0;
    return random;
  }

  void moveAsteroid() {
    Alignment asteroid1 = asteroidData[0].alignment;
    Alignment asteroid2 = asteroidData[1].alignment;
    Alignment asteroid3 = asteroidData[2].alignment;
    Alignment asteroid4 = asteroidData[3].alignment;

    if (asteroid1.x > -1.4) {
      asteroidData[0].alignment = Alignment(asteroid1.x - 0.02, asteroid1.y);
    } else {
      asteroidData[0].alignment = Alignment(2, generateRandomNumber());
    }
    if (asteroid2.x > -1.4) {
      asteroidData[1].alignment = Alignment(asteroid2.x - 0.02, asteroid2.y);
    } else {
      asteroidData[1].alignment = Alignment(1.5, generateRandomNumber());
    }
    if (asteroid3.x > -1.4) {
      asteroidData[2].alignment = Alignment(asteroid3.x - 0.02, asteroid3.y);
    } else {
      asteroidData[2].alignment = Alignment(3, generateRandomNumber());
    }
    if (asteroid4.x > -1.4) {
      asteroidData[3].alignment = Alignment(asteroid4.x - 0.02, asteroid4.y);
    } else {
      asteroidData[3].alignment = Alignment(2.2, generateRandomNumber());
    }

    if (asteroid1.x <= 0.021 && asteroid1.x >= 0.001){
      score++;
    }
    if (asteroid2.x <= 0.021 && asteroid2.x >= 0.001){
      score++;
    }
    if (asteroid3.x <= 0.021 && asteroid3.x >= 0.001){
      score++;
    }
    if (asteroid4.x <= 0.021 && asteroid4.x >= 0.001){
      score++;
    }

  }

  bool isShipColided() {
    if (shipY > 1) {
      return true;
    } else if (shipY < -0.95) {
      return true;
    }else if (checkCollision()) {
      return true;
    } else {
      return false;
    }
  }

  void restData() {
    asteroidData = setAsteroidData();
    shipX = 0.0;
    shipY = 0.0;
    maxHeight = 0.0;
    initialPosition = 0.0;
    time = 0.0;
    velocity = 2.9;
    gravity = -4.9;
    isGameStart = false;
    score = 0;
  }

  bool checkCollision() {
    RenderBox shipRenderBox =
        shipGlobalKey.currentContext!.findRenderObject() as RenderBox;
    bool isCollided = false;

    List<CollisionData> collisionData = [];

    for (var element in globalKeys) {
      RenderBox renderBox =
          element.currentContext!.findRenderObject() as RenderBox;

      collisionData.add(
        CollisionData(
            sizeOfObject: renderBox.size,
            positionOfBox: renderBox.localToGlobal(Offset.zero)),
      );
    }

    for (var element in collisionData) {
      final shipPosition = shipRenderBox.localToGlobal(Offset.zero);
      final asteroidPosition = element.positionOfBox;
      final asteroidSize = element.sizeOfObject;
      final shipSize = shipRenderBox.size;

      bool _isCollided =
          (shipPosition.dx < asteroidPosition.dx + asteroidSize.width &&
              shipPosition.dx + shipSize.width > asteroidPosition.dx &&
              shipPosition.dy < asteroidPosition.dy + asteroidSize.height &&
              shipPosition.dy + shipSize.height > asteroidPosition.dy);

      if(_isCollided){
        isCollided = true;
        break;
      }else{
        isCollided = false;
      }
    }

    return isCollided;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    asteroidData = setAsteroidData();
    initGlobalKeys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: isGameStart ? onJump : startGame,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: AssetImage(
              "assets/space.jpeg",
            ),
            fit: BoxFit.cover,
          )),
          child: Stack(
            children: [
              Align(
                alignment: Alignment(shipX, shipY),
                child: Container(
                  key: shipGlobalKey,
                  height: 50,
                  width: 70,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/ship2.jpg"))),
                ),
              ),
              Align(
                alignment: asteroidData[0].alignment,
                child: Container(
                  key: globalKeys[0],
                  height: asteroidData[0].size.height,
                  width: asteroidData[0].size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                      asteroidData[0].path,
                    )),
                  ),
                ),
              ),
              Align(
                alignment: asteroidData[1].alignment,
                child: Container(
                  key: globalKeys[1],
                  height: asteroidData[1].size.height,
                  width: asteroidData[1].size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                      asteroidData[1].path,
                    )),
                  ),
                ),
              ),
              Align(
                alignment: asteroidData[2].alignment,
                child: Container(
                  key: globalKeys[2],
                  height: asteroidData[2].size.height,
                  width: asteroidData[2].size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                      asteroidData[2].path,
                    )),
                  ),
                ),
              ),
              Align(
                alignment: asteroidData[3].alignment,
                child: Container(
                  key: globalKeys[3],
                  height: asteroidData[3].size.height,
                  width: asteroidData[3].size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                      asteroidData[3].path,
                    )),
                  ),
                ),
              ),
              isGameStart
                  ? const SizedBox()
                  : const Align(
                      alignment: Alignment(0, -0.3),
                      child: Text(
                        "Tap To Play",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),

               Align(
                alignment: const Alignment(0, 0.95),
                child: Text(
                  "Score : $score",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
