import 'package:flutter/material.dart';

class OnlineLobbyScreen extends StatelessWidget {
  const OnlineLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Online Lobby')),
      body: const Center(child: Text('Online Lobby Screen')),
    );
  }
}
