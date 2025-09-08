import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
    Color(0xFFffe5ff),
    Color(0xFFfeefd0),
    // Colors.purple.shade100,
    Color(0xffafda95),
    Color(0xffc7e2f6),
    Color(0xff8fe1ff),
    Color(0xfff09ea5),
    Color(0xffc4b4db),
    Colors.white,
    Color(0xffaffaff),

    Color(0xfffdf3b1),
    Color(0xffb3e0fc),
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
    "assets/images/Olride.png",
    "assets/images/Salzina.png",
    "assets/images/I_Pill.png",
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

      if (names.indexOf("Prize") == selected) {
        _confettiController.play();
        await player.setReleaseMode(ReleaseMode.loop);
        await player.play(AssetSource("sounds/correct2.wav"));
      } else {
        await player.setReleaseMode(ReleaseMode.release);
        await player.play(AssetSource("sounds/better_luck.mp3"));
      }

      final mediaQuerySize = MediaQuery.of(context).size;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return Stack(
            children: [
              if (names.indexOf("Prize") == selected)
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
                        emissionFrequency: 0.8,
                        numberOfParticles: 160,
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
                contentPadding: EdgeInsets.only(
                  left: mediaQuerySize.width * 0.02,
                  right: mediaQuerySize.width * 0.02,
                  top: mediaQuerySize.height * 0.03,
                  bottom: mediaQuerySize.height * 0.02,
                ),
                content: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            mediaQuerySize.width *
                            0.85, // ✅ screen width ka 85%
                        // maxHeight: mediaQuerySize.height * 0.70,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              images[selected],
                              height: mediaQuerySize.height * 0.25,
                              fit: BoxFit.contain,
                            ),

                            SizedBox(height: 12.h),
                            if (names[selected] == "Prize") ...[
                              Transform.scale(
                                scale: 6,
                                child: Lottie.asset(
                                  "assets/lottie/Congratulation.json",
                                  repeat: true,
                                  width: mediaQuerySize.width * 0.5,
                                  height: mediaQuerySize.height * 0.2,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              SizedBox(height: 12.h),

                              SizedBox(height: 8.h),

                              Text(
                                "Winner: ${names[selected]}",
                                style: TextStyle(
                                  fontSize: mediaQuerySize.height * 0.025,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ] else ...[
                              Text(
                                "Better Luck Next Time!",
                                style: TextStyle(
                                  fontSize: mediaQuerySize.height * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],

                            // ✅ Lottie animation
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
                                  fontSize: mediaQuerySize.height * 0.025,
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // spacing: 10,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/Genix.gif",
                      height: mediaQuerySize.height * 0.2,
                    ),
                    Text(
                      "Spin N Win",
                      style: TextStyle(
                        fontSize:
                            mediaQuerySize.width * 0.025, // screen width ka 5%
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
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
                            alignment: Alignment.topCenter,
                            child: TriangleIndicator(
                              color: Colors.black,
                              width: mediaQuerySize.width * 0.03,
                              height: mediaQuerySize.height * 0.05,
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
                                color: colors[i],
                                borderColor: Colors.black45,
                                borderWidth: 10.w,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: isSpinning ? null : spinWheel,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          mediaQuerySize.width * 0.02, // screen width ka 8%
                      vertical:
                          mediaQuerySize.height * 0.02, // screen height ka 2%
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        mediaQuerySize.width * 0.1,
                      ), // responsive radius
                    ),
                    backgroundColor:
                        isSpinning ? Colors.grey : Colors.blueAccent,
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
                    onDoubleTap:
                        () => setState(() => chosenOption = 2), // prize
                    child: SizedBox(
                      height: 50.h,
                      width: 50.w,
                      child: Text("__"),
                    ),
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
      ),
    );
  }
}
