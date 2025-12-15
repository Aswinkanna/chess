import 'package:flutter/material.dart';

class Tile extends StatelessWidget {
  final Color color;
  final Widget? child;
  final VoidCallback? onTap;

  // New flags for highlighting & target marker
  final bool highlight;     // selected square highlight
  final bool isMoveTarget;  // target indicator (dot)

  const Tile({
    super.key,
    required this.color,
    this.child,
    this.onTap,
    this.highlight = false,
    this.isMoveTarget = false,
  });

  @override
  Widget build(BuildContext context) {
    // Build a stack so we can show piece, highlight outline and small dot for targets
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: highlight
              ? Border.all(color: Colors.yellowAccent.shade700, width: 4)
              : null,
        ),
        child: Stack(
          children: [
            // Center the piece or other child
            Center(child: child),
            // If it's a legal move target, show a small circle at the bottom center
            if (isMoveTarget)
              Align(
                alignment: Alignment(0, 0.7),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.yellowAccent.shade700,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
