// import 'package:flutter/material.dart';
// import '../services/ai_engine.dart';
// import 'play_ai_screen.dart';

// class DifficultyScreen extends StatelessWidget {
//   const DifficultyScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Choose Difficulty')),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _btn(context, 'Easy', Difficulty.easy),
//           _btn(context, 'Medium', Difficulty.medium),
//           _btn(context, 'Hard', Difficulty.hard),
//         ],
//       ),
//     );
//   }

//   Widget _btn(BuildContext context, String label, Difficulty d) {
//     return Padding(
//       padding: const EdgeInsets.all(8),
//       child: ElevatedButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => PlayAiScreen(difficulty: d), // ✅ REQUIRED
//             ),
//           );
//         },
//         child: Text(label),
//       ),
//     );
//   }
// }
