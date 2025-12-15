// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/ai_engine.dart';
// import '../models/chess_state.dart';
// import '../widgets/chess_board_widget.dart';

// class PlayAiScreen extends StatelessWidget {
//   final Difficulty difficulty;

//   const PlayAiScreen({
//     super.key,
//     required this.difficulty,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Play vs AI (${difficulty.name})'),
//       ),
//       body: ChangeNotifierProvider(
//         create: (_) => ChessState(difficulty: difficulty),
//         child: const ChessBoardWidget(),
//       ),
//     );
//   }
// }
