import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  Wind.instance.mainLoop();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Rain',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Rain(),
    );
  }
}

class Rain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ...List.generate(
            1000,
            (_) => Particle(
              key: UniqueKey(),
              screenWidth: MediaQuery.of(context).size.width * 5,
            ),
          )
        ],
      ),
    );
  }
}

class Wind {
  Wind._();
  static Wind instance = Wind._();
  final random = Random();
  double xVelocity = 0;
  int yVelocity = 0;

  int time = 0;
  bool play = true;

  void changeWindow() {
    xVelocity = xVelocity + (random.nextDouble() - .5) / 10;
    yVelocity = random.nextInt(5);
  }

  Future<void> mainLoop() async {
    int count = 0;
    time = random.nextInt(500);

    while (play) {
      await Future.delayed(const Duration(milliseconds: 100));
      count++;
      changeWindow();
      if (count > time) {
        count = 0;
        time = random.nextInt(500);
        xVelocity = xVelocity + (random.nextDouble() - .5) * 2;
      }
    }
  }
}

class Particle extends StatefulWidget {
  Particle({required Key key, required this.screenWidth}) : super(key: key);
  final double screenWidth;

  @override
  _ParticleState createState() => _ParticleState();
}

class _ParticleState extends State<Particle> with SingleTickerProviderStateMixin {
  late AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );
  late double initXPos;
  late double initYPos;
  late double strokeWidth;
  late double length;
  late double disappearanceTime;

  var count = 0;
  @override
  void initState() {
    super.initState();
    reset();
    animationController.addListener(() {
      count++;
      if (count > disappearanceTime) {
        reset();
      }
    });
    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void reset() {
    final random = Random();
    count = 0;
    initXPos = (random.nextDouble() * widget.screenWidth) - widget.screenWidth * (2 / 5);
    initYPos = -random.nextDouble() * 1000;
    strokeWidth = random.nextDouble() / 4;
    length = random.nextDouble() * 280;
    disappearanceTime = 10 + random.nextDouble() * 100;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            xPos: initXPos + (count * Wind.instance.xVelocity * 80.0),
            yPos: initYPos + (count * (Wind.instance.yVelocity + 80.0)),
            strokeWidth: strokeWidth,
            length: length,
            xVelocity: Wind.instance.xVelocity,
          ),
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  ParticlePainter({
    required this.xPos,
    required this.yPos,
    required this.strokeWidth,
    required this.length,
    required this.xVelocity,
  });

  final double xPos;
  final double yPos;
  final double strokeWidth;
  final double length;
  final double xVelocity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = Random();
    final fluctuation = random.nextDouble() / 50;
    paint.strokeWidth = strokeWidth;
    paint.color = Colors.white;
    canvas.drawLine(
      Offset(xPos, yPos),
      Offset(xPos + (xVelocity + fluctuation) * (40 + length), yPos + 40 + length),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
