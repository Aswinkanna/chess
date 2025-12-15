import 'package:flutter/material.dart';

class AnimatedPiece extends StatelessWidget {
  final String assetPath;
  final double size;

  const AnimatedPiece({
    super.key,
    required this.assetPath,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(assetPath, width: size, height: size, fit: BoxFit.contain);
  }
}
