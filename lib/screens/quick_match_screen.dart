import 'package:flutter/material.dart';

class QuickMatchScreen extends StatelessWidget {
  const QuickMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Match')),
      body: const Center(child: Text('Quick Match Screen')),
    );
  }
}
