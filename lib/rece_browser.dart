import 'dart:html'; // for web
import 'package:flutter/material.dart';

class ReceiverWebApp extends StatefulWidget {
  const ReceiverWebApp({super.key});

  @override
  State<ReceiverWebApp> createState() => _ReceiverWebAppState();
}

class _ReceiverWebAppState extends State<ReceiverWebApp> {
  WebSocket? socket;
  String received = '0';
  final TextEditingController ipController = TextEditingController();
  bool connected = false;

  void connect() {
    final ip = ipController.text.trim();
    if (ip.isEmpty) return;

    socket = WebSocket('ws://$ip:8080/ws');

    socket!.onOpen.listen((_) {
      setState(() => connected = true);
    });

    socket!.onMessage.listen((MessageEvent event) {
      setState(() => received = event.data.toString());
    });

    socket!.onClose.listen((_) {
      setState(() => connected = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Receiver (WebSocket Web)')),
        body: Center(
          child:
              connected
                  ? Text('Received: $received', style: TextStyle(fontSize: 40))
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: ipController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter Sender IP (e.g. 192.168.43.1)',
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: connect,
                        child: Text('Connect'),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
