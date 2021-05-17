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
      theme: ThemeData(),
      home: RainWidget(),
    );
  }
}

class RainWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Particle(),
    );
  }
}

class Particle extends StatefulWidget {
  @override
  _ParticleState createState() => _ParticleState();
}

class _ParticleState extends State<Particle> with SingleTickerProviderStateMixin {
  final rainList = List<Rain>.generate(500, (index) => Rain());

  late AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  var count = 0;
  @override
  void initState() {
    super.initState();
    animationController.addListener(() {
      rainList.forEach((e) => e.update());
    });
    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(
        rainList: rainList,
        controller: animationController,
      ),
    );
  }
}

class Rain {
  Rain() {
    init();
  }
  static final random = Random();
  late double xPos;
  late double yPos;
  late double xVelocity = 0;
  final double yVelocity = 40;
  late double resetTime;
  late int magnitude;
  late double strokeWidth;

  void init() {
    xPos = (random.nextDouble() - .5) * 5000;
    yPos = -random.nextDouble() * 1000;
    magnitude = 10 + random.nextInt(11);
    resetTime = 100 + random.nextDouble() * 100;
    strokeWidth = random.nextDouble() / 4;
  }

  void update() {
    xPos += xVelocity + Wind.instance.xVelocity;
    yPos += yVelocity;

    if (yPos > 1000) {
      init();
    }
  }
}

class ParticlePainter extends CustomPainter {
  ParticlePainter({
    required this.rainList,
    required this.controller,
  }) : super(repaint: controller);

  final List<Rain> rainList;
  final AnimationController controller;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.white;

    for (final rain in rainList) {
      paint.strokeWidth = rain.strokeWidth;
      canvas.drawLine(
        Offset(rain.xPos, rain.yPos),
        Offset(
          rain.xPos + ((rain.xVelocity + Wind.instance.xVelocity) * rain.magnitude),
          rain.yPos + ((rain.yVelocity + Wind.instance.yVelocity) * rain.magnitude),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Wind {
  Wind._();
  static Wind instance = Wind._();
  final random = Random();
  double xVelocity = 0;
  int yVelocity = 0;

  /// 風が吹くタイミングを決定する
  int time = 0;

  /// 風向きを変える
  void changeWindow() {
    xVelocity = xVelocity + (random.nextDouble() - .5) / 4;
    yVelocity = random.nextInt(5);
  }

  Future<void> mainLoop() async {
    int count = 0;
    time = random.nextInt(500);
    while (true) {
      await Future.delayed(const Duration(milliseconds: 100));
      count++;
      changeWindow();
      if (count > time) {
        count = 0;
        time = random.nextInt(500);
        xVelocity = xVelocity + (random.nextDouble() - .5) * 20;
      }
    }
  }
}
