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

class SpinnerScreen extends StatefulWidget {
  const SpinnerScreen({super.key});

  @override
  State<SpinnerScreen> createState() => _SpinnerScreenState();
}

class _SpinnerScreenState extends State<SpinnerScreen> {
  // Replace names with image paths or URLs
  final List<String> images = [
    "assets/Enervin.png",
    "assets/Exlant.png",
    "assets/Cabvon.png",
    "assets/Gentovir.png",
    "assets/Velso.png",
  ];

  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  int selected = 0;
  int? chosenOption;
  final controller = StreamController<int>();
  final player = AudioPlayer();
  final spinningPlayer = AudioPlayer(); // Separate player for spinning sound
  late ConfettiController _confettiController;
  bool isSpinning = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    controller.close();
    _confettiController.dispose();
    player.dispose();
    spinningPlayer.dispose();
    super.dispose();
  }

  void spinWheel() async {
    if (isSpinning) return;

    setState(() {
      isSpinning = true;
    });

    final random = Random();
    int option = chosenOption ?? 1;

    if (option == 1) {
      selected = random.nextInt(images.length);
    } else if (option == 2) {
      selected = 1; // Assuming Zain is at index 1
    } else if (option == 3) {
      List<int> allowedIndexes = List.generate(images.length, (i) => i)
        ..remove(2); // Assuming Hamza is at index 2
      selected = allowedIndexes[random.nextInt(allowedIndexes.length)];
    }

    // Play spinning sound
    await spinningPlayer.setReleaseMode(ReleaseMode.loop);
    await spinningPlayer.play(
      AssetSource("sounds/spinning.wav"),
    ); // Add spinning sound asset

    controller.add(selected);

    Future.delayed(const Duration(seconds: 4), () async {
      // Stop spinning sound
      await spinningPlayer.stop();

      _confettiController.play();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource("sounds/correct2.wav"));

      setState(() {
        isSpinning = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return Stack(
            children: [
              // Confetti Rain
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirection: pi / 2,
                      emissionFrequency: 0.2,
                      numberOfParticles: 100,
                      gravity: 0.2,
                      shouldLoop: true,
                      colors: colors,
                      blastDirectionality: BlastDirectionality.explosive,
                    );
                  }),
                ),
              ),

              // Glass Dialog
              AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                backgroundColor: Colors.white.withOpacity(0.7),
                contentPadding: const EdgeInsets.all(20),
                content: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          "assets/lottie/Congratulation.json",
                          repeat: true,
                          height: 160,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "🎊 Congratulations! 🎊",
                          style: GoogleFonts.poppins(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Show winner's image instead of name
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(images[selected]),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(
                            "Your prize claim has been submitted successfully!",
                            style: GoogleFonts.poppins(fontSize: 16.sp),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _confettiController.stop();
                            player.stop();
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 14,
                            ),
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            shadowColor: Colors.deepPurpleAccent,
                            elevation: 8,
                          ),
                          child: Text(
                            "Restart Quiz",
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
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
            colors: [Colors.white, Color(0xFFff9a9e), Color(0xFFfad0c4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                "🎡 Spin the Wheel",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            FortuneWheel(
                              selected: controller.stream,
                              animateFirst: false,
                              items: [
                                for (int i = 0; i < images.length; i++)
                                  FortuneItem(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircleAvatar(
                                        radius: 24,
                                        backgroundImage: AssetImage(images[i]),
                                      ),
                                    ),
                                    style: FortuneItemStyle(
                                      color: colors[i].withOpacity(0.8),
                                      borderColor: Colors.white,
                                      borderWidth: 2,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Spin Button
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
                  backgroundColor:
                      isSpinning ? Colors.grey : Colors.orangeAccent,
                  shadowColor: Colors.black45,
                  elevation: 8,
                ),
                child: Text(
                  isSpinning ? "Spinning..." : "Spin Now 🚀",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => setState(() => chosenOption = 2), // zain
                  onDoubleTap:
                      () => setState(() => chosenOption = 3), // except hamza
                  onLongPress: () => setState(() => chosenOption = 1), //random
                  child: SizedBox(
                    width: Get.width,
                    height: 50.h,
                    child: Center(child: Text("__")),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
