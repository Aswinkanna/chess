import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    void adjust(int delta) {
      UserService.instance.adjustBalance(user.uid, delta);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<UserProfile?>(
          stream: UserService.instance.watchProfile(user.uid),
          builder: (context, snapshot) {
            final balance = snapshot.data?.balance ?? 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Balance: $balance coins', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                Text('Use coins to enter bet matches.'),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: () => adjust(100),
                      child: const Text('+100 demo coins'),
                    ),
                    ElevatedButton(
                      onPressed: balance >= 100 ? () => adjust(-100) : null,
                      child: const Text('Spend 100'),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Note: demo wallet only. Wire real payments or consumables\nif you want production-grade economy.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

