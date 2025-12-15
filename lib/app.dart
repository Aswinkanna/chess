import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'models/chess_state.dart';
import 'screens/auth_gate.dart';

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChessState(),
      child: MaterialApp(
        title: 'Flutter Chess',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}
