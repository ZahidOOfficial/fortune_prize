import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final List<String> names = [
    "Cabvon",
    "Enervin",
    "Exlant",
    "Gentovir",
    "Movcol",
    "Velso",
    "Wymly",
    "Prize",
  ];

  final List<Color> colors = [
    Colors.white,
    Colors.purple.shade100,
    Colors.greenAccent.shade100,
    Colors.yellow.shade100,
    Colors.orange.shade200,
    Colors.amber.shade100,
    Colors.lightBlueAccent.shade100,
    Colors.pink,
  ];

  final List<String> images = [
    "assets/images/Cabvon.png",
    "assets/images/Enervin.png",
    "assets/images/Exlant.png",
    "assets/images/Gentovir.png",
    "assets/images/Movcol.png",
    "assets/images/Velso.png",
    "assets/images/Wymly.png",
    "assets/images/Prize.png",
  ];

  int selected = 0;
  int? chosenOption;
  final controller = StreamController<int>();
  final player = AudioPlayer();
  final spinPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  bool isSpinning = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(hours: 1),
    );
  }

  @override
  void dispose() {
    controller.close();
    _confettiController.dispose();
    player.dispose();
    spinPlayer.dispose();
    super.dispose();
  }

  void spinWheel() async {
    if (isSpinning) return;

    setState(() {
      isSpinning = true;
    });

    final random = Random();
    int option = chosenOption ?? 3;

    if (option == 1) {
      selected = random.nextInt(names.length);
    } else if (option == 2) {
      selected = names.indexOf("Prize");
    } else if (option == 3) {
      List<int> allowedIndexes = List.generate(names.length, (i) => i)
        ..remove(names.indexOf("Prize"));
      selected = allowedIndexes[random.nextInt(allowedIndexes.length)];
    }

    await spinPlayer.setReleaseMode(ReleaseMode.loop);
    await spinPlayer.play(AssetSource("sounds/trick.mp3"));

    controller.add(selected);

    Future.delayed(const Duration(seconds: 4), () async {
      await spinPlayer.stop();

      setState(() {
        isSpinning = false;
      });

      _confettiController.play();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource("sounds/correct2.wav"));

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirection: pi / 2,
                      emissionFrequency: 0.2,
                      numberOfParticles: 60,
                      gravity: 0.2,
                      shouldLoop: true,
                      colors: colors,
                      blastDirectionality: BlastDirectionality.explosive,
                    );
                  }),
                ),
              ),
              AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                backgroundColor: Colors.white.withOpacity(0.75),
                contentPadding: EdgeInsets.all(20.w), // responsive padding
                content: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 0.85.sw, // screen width ka 85%
                        maxHeight: 0.70.sh, // screen height ka 70%
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(35.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ✅ Winner ki image
                              Image.asset(
                                images[selected],
                                height: 120.h,
                                fit: BoxFit.contain,
                              ),

                              SizedBox(height: 12.h),

                              // ✅ Lottie animation
                              Lottie.asset(
                                "assets/lottie/Congratulation.json",
                                repeat: true,
                                height: 160.h,
                              ),

                              SizedBox(height: 12.h),

                              Text(
                                "🎊 Congratulations! 🎊",
                                style: TextStyle(
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 8.h),

                              Text(
                                "Winner: ${names[selected]}",
                                style: TextStyle(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 20.h),

                              ElevatedButton(
                                onPressed: () {
                                  _confettiController.stop();
                                  player.stop();
                                  Get.back();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 40.w,
                                    vertical: 14.h,
                                  ),
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  shadowColor: Colors.black38,
                                  elevation: 6,
                                ),
                                child: Text(
                                  "Restart",
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFb3e5fc), Color(0xFF81d4fa)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10.h),
              Text(
                "🎡 SPIN THE WHEEL",
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20.h),

              // Wheel adjust with screen
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1, // always square
                    child: FortuneWheel(
                      selected: controller.stream,
                      animateFirst: false,
                      duration: const Duration(seconds: 4),
                      items: [
                        for (int i = 0; i < names.length; i++)
                          FortuneItem(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.only(right: 35.h),
                                child: Text(
                                  names[i],
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 50.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),

                            style: FortuneItemStyle(
                              color: colors[i].withValues(alpha: 0.85),
                              borderColor: Colors.white,
                              borderWidth: 2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              ElevatedButton(
                onPressed: isSpinning ? null : spinWheel,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  backgroundColor: isSpinning ? Colors.grey : Colors.blueAccent,
                  elevation: 8,
                ),
                child: Text(
                  isSpinning ? "Spinning..." : "Spin Now 🚀",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              GestureDetector(
                onTap: () => setState(() => chosenOption = 3), // random
                onDoubleTap: () => setState(() => chosenOption = 2), // prize
                child: SizedBox(
                  width: Get.width,
                  height: 50.h,
                  child: const Center(child: Text("__")),
                ),
              ),

              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  chosenOption.toString(),
                  style: TextStyle(fontSize: 8.sp),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
