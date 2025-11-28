// import 'dart:io';

// import 'package:flutter/material.dart';

// class ReceiverScreen extends StatefulWidget {
//   const ReceiverScreen({super.key});

//   @override
//   _ReceiverScreenState createState() => _ReceiverScreenState();
// }

// class _ReceiverScreenState extends State<ReceiverScreen> {
//   String receivedValue = '0';
//   Socket? socket;
//   final TextEditingController ipController = TextEditingController();

//   bool isConnected = false;

//   void connectToServer(String ip) async {
//     try {
//       socket = await Socket.connect(ip, 4567);
//       print('✅ Connected to $ip');
//       setState(() => isConnected = true);

//       socket!.listen(
//         (data) {
//           final msg = String.fromCharCodes(data).trim();
//           print('📩 Received: $msg');
//           setState(() => receivedValue = msg);
//         },
//         onDone: () {
//           print('❌ Disconnected from server');
//           setState(() => isConnected = false);
//         },
//       );
//     } catch (e) {
//       print('⚠️ Connection error: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to connect: $e')));
//     }
//   }

//   @override
//   void dispose() {
//     socket?.destroy();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Receiver App')),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (!isConnected) ...[
//               const Text(
//                 'Enter Sender IP Address:',
//                 style: TextStyle(fontSize: 18),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: ipController,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                   hintText: 'e.g. 192.168.43.1',
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if (ipController.text.isNotEmpty) {
//                     connectToServer(ipController.text.trim());
//                   }
//                 },
//                 child: const Text('Connect'),
//               ),
//             ] else ...[
//               Text(
//                 'Connected ✅',
//                 style: const TextStyle(
//                   fontSize: 20,
//                   color: Colors.green,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 40),
//               Text('Received Value:', style: const TextStyle(fontSize: 18)),
//               Text(
//                 receivedValue,
//                 style: const TextStyle(
//                   fontSize: 60,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   socket?.destroy();
//                   setState(() => isConnected = false);
//                 },
//                 child: const Text('Disconnect'),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class ReceiverScreen extends StatefulWidget {
  const ReceiverScreen({super.key});

  @override
  _ReceiverScreenState createState() => _ReceiverScreenState();
}

class _ReceiverScreenState extends State<ReceiverScreen> {
  String receivedValue = '0';
  Socket? socket;
  bool isConnected = false;
  RawDatagramSocket? udpSocket;

  @override
  void initState() {
    super.initState();
    _listenForSender();
  }

  @override
  void dispose() {
    socket?.destroy();
    udpSocket?.close();
    super.dispose();
  }

  void _listenForSender() async {
    udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4568);
    print('🔍 Listening for sender broadcasts...');
    udpSocket!.listen((event) {
      if (event == RawSocketEvent.read) {
        Datagram? dg = udpSocket!.receive();
        if (dg != null) {
          final msg = utf8.decode(dg.data);
          if (msg.startsWith('SENDER_IP:') && !isConnected) {
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
      setState(() => isConnected = true);

      socket!.listen(
        (data) {
          final msg = String.fromCharCodes(data).trim();
          print('📩 Received: $msg');
          setState(() => receivedValue = msg);
        },
        onDone: () {
          print('❌ Disconnected from server');
          setState(() => isConnected = false);
        },
      );
    } catch (e) {
      print('⚠️ Connection error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receiver App')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child:
              isConnected
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Connected ✅',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Received Value:',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        receivedValue,
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          socket?.destroy();
                          setState(() => isConnected = false);
                        },
                        child: const Text('Disconnect'),
                      ),
                    ],
                  )
                  : const Text(
                    'Searching for sender on the network...',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
        ),
      ),
    );
  }
}
