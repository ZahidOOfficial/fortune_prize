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

class ImageWheel extends StatefulWidget {
  const ImageWheel({super.key});

  @override
  State<ImageWheel> createState() => _ImageWheelState();
}

class _ImageWheelState extends State<ImageWheel> {
  final List<String> names = [
    "Cabvon",
    "Enervin",
    "Exlant",
    "Gentovir",
    "Movcol",
    "Velso",
    "Wymly",
    "Prize",
    "Olride",
    "Salzina",
    "I_Pill",
  ];

  final List<Color> colors = [
    Colors.white,
    Colors.pink.shade100,
    // Colors.purple.shade100,
    Colors.greenAccent.shade100,
    Colors.yellow.shade100,
    Colors.orange.shade200,
    Colors.amber.shade100,
    Colors.lightBlueAccent.shade100,
    Colors.teal.shade100,
    Colors.lime.shade100,
    Colors.indigo.shade100,
    Colors.red.shade100,
  ];

  final List<String> images = [
    "assets/images/Cabvon.png",
    "assets/images/Enervin.png",
    "assets/images/Exlant.png",
    "assets/images/Gentovir.png",
    "assets/images/Movcol.png",
    "assets/images/Velso.png",
    "assets/images/Wymly.png",
    "assets/images/Olride.png",
    "assets/images/Salzina.png",
    "assets/images/I_Pill.png",
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

      final mediaQuerySize = MediaQuery.of(context).size;

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
                backgroundColor: Colors.white.withValues(alpha: 0.75),
                contentPadding: EdgeInsets.all(mediaQuerySize.width * 0.05),
                content: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            mediaQuerySize.width *
                            0.85, // ✅ screen width ka 85%
                        maxHeight: mediaQuerySize.height * 0.70,
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
                                  setState(() {
                                    chosenOption = 3;
                                  });
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
    final mediaQuerySize = MediaQuery.of(context).size;

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
              // SizedBox(height: 10.h),
              // Text(
              //   "🎡 Spin the Wheel",
              //   style: TextStyle(
              //     fontSize: 28.sp,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.black87,
              //   ),
              // ),
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
                      indicators: <FortuneIndicator>[
                        FortuneIndicator(
                          alignment: Alignment.topCenter, // pointer ki position
                          child: TriangleIndicator(
                            color: Colors.black,
                            width:
                                mediaQuerySize.width *
                                0.03, // ✅ pointer ka width
                            height:
                                mediaQuerySize.height *
                                0.05, // ✅ pointer ka height
                          ),
                        ),
                      ],
                      items: [
                        for (int i = 0; i < names.length; i++)
                          FortuneItem(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 35.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  height: mediaQuerySize.height * 0.10,
                                  width: mediaQuerySize.width * 0.10,
                                  child: Image.asset(
                                    images[i],
                                    fit: BoxFit.contain,
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

              SizedBox(height: 30.h),

              ElevatedButton(
                onPressed: isSpinning ? null : spinWheel,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        mediaQuerySize.width * 0.08, // screen width ka 8%
                    vertical:
                        mediaQuerySize.height * 0.02, // screen height ka 2%
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      mediaQuerySize.width * 0.1,
                    ), // responsive radius
                  ),
                  backgroundColor: isSpinning ? Colors.grey : Colors.blueAccent,
                  elevation: 8,
                ),
                child: Text(
                  isSpinning ? "Spinning..." : "Spin Now 🚀",
                  style: TextStyle(
                    fontSize:
                        mediaQuerySize.width * 0.015, // screen width ka 5%
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () => setState(() => chosenOption = 3), // random
                  onDoubleTap: () => setState(() => chosenOption = 2), // prize
                  child: SizedBox(height: 50.h, width: 50.w, child: Text("__")),
                ),
              ),
              if (chosenOption != null)
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
