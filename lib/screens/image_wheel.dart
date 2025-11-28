import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wheel_app/utils.dart';

class ImageWheel extends StatefulWidget {
  const ImageWheel({super.key});

  @override
  State<ImageWheel> createState() => _ImageWheelState();
}

class _ImageWheelState extends State<ImageWheel> {
  int selected = 0;
  int? chosenOption;
  final controller = StreamController<int>();
  final player = AudioPlayer();
  final spinPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  bool isSpinning = false;

  Socket? socket;
  RawDatagramSocket? udpSocket;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(hours: 1),
    );
    _listenForSender();
  }

  @override
  void dispose() {
    controller.close();
    _confettiController.dispose();
    player.dispose();
    spinPlayer.dispose();
    socket?.destroy();
    udpSocket?.close();
    super.dispose();
  }

  // ---------------- Network Receiver ----------------
  void _listenForSender() async {
    udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4568);
    udpSocket!.broadcastEnabled = true;
    print('🔍 Listening for sender broadcasts...');
    udpSocket!.listen((event) {
      if (event == RawSocketEvent.read) {
        Datagram? dg = udpSocket!.receive();
        if (dg != null) {
          final msg = utf8.decode(dg.data).trim();
          if (msg.startsWith('SENDER_IP:') && socket == null) {
            final senderIp = msg.split(':')[1];
            print('📡 Discovered sender: $senderIp');
            _connectToServer(senderIp);
          }
        }
      }
    });
  }

  void _connectToServer(String ip) async {
    try {
      socket = await Socket.connect(
        ip,
        4567,
        timeout: const Duration(seconds: 5),
      );
      print('✅ Connected to $ip');

      socket!.listen(
        (data) {
          final msg = utf8.decode(data).trim();
          for (var line in LineSplitter.split(msg)) {
            print('📩 Received: $line');
            setState(() {
              if (line == "1") {
                chosenOption = 2; // prize
              } else if (line == "0") {
                chosenOption = 3; // non-prize
              } else {
                chosenOption = 3;
              }
            });
          }
        },
        onDone: () {
          print('❌ Disconnected from server');
          socket = null;
        },
      );
    } catch (e) {
      print('⚠️ Connection error: $e');
    }
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
          return _dialogContent(mediaQuerySize);
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.purple.shade200, Color(0xFF81d4fa)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset("assets/images/Genix.gif"),
                  ),
                ),
                Center(
                  child: AspectRatio(
                    aspectRatio: 1, // always square
                    child: Stack(
                      // 👈 Wrap the wheel with a Stack
                      children: [
                        IgnorePointer(
                          ignoring: true,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade300,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey.shade200,
                                  Colors.grey.shade400,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    0.25,
                                  ), // shadow color
                                  blurRadius: 15, // softness of shadow
                                  spreadRadius: 2, // how wide it spreads
                                  offset: Offset(
                                    0,
                                    8,
                                  ), // x, y position of shadow
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FortuneWheel(
                                selected: controller.stream,
                                animateFirst: false,
                                duration: const Duration(seconds: 4),
                                indicators: <FortuneIndicator>[
                                  FortuneIndicator(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 50.w),
                                      child: Image.asset(
                                        "assets/images/s1.png",
                                        height: 180.h,
                                      ),
                                    ),
                                  ),
                                ],
                                items: [
                                  for (int i = 0; i < names.length; i++)
                                    FortuneItem(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 30.0,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: SizedBox(
                                            height:
                                                mediaQuerySize.height * 0.10,
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
                                        borderColor: darkColors[i],
                                        borderWidth: 1.w,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 🌟 Circular Start Button in Center 🌟
                        Center(
                          child: ElevatedButton(
                            onPressed:
                                isSpinning
                                    ? () {}
                                    : spinWheel, // Disable when spinning
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: const CircleBorder(),
                              padding: EdgeInsets.all(6.0.w),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                isSpinning ? "Spinning..." : "Start",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Spin & Win",
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogContent(Size mediaQuerySize) {
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
                      mediaQuerySize.width * 0.85, // ✅ screen width ka 85%
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
  }
}
