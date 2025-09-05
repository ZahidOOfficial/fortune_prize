import 'package:flutter/material.dart';

class WheelScreen extends StatelessWidget {
  const WheelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Column(children: [Text("Wheel Screen")])),
        Expanded(
          child: Column(
            children: [
              ColoredBox(color: Colors.amber, child: Text("Wheel Screen")),
            ],
          ),
        ),
        Expanded(child: Column(children: [Text("Wheel Screen")])),
      ],
    );
  }
}
