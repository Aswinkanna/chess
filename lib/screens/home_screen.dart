import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'chess_screen.dart';
import 'online_lobby_screen.dart';
import 'profile_screen.dart';
import 'wallet_screen.dart';
import 'bet_match_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purple Royale'),
        actions: [
          IconButton(
            onPressed: () => AuthService.instance.signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.deepPurple.shade300,
                  child: Text(
                    (user?.displayName?.substring(0, 1) ?? '?').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder<UserProfile?>(
                    stream: user == null ? null : UserService.instance.watchProfile(user.uid),
                    builder: (context, snapshot) {
                      final profile = snapshot.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? user?.email ?? 'Player',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text('Balance: ${profile?.balance ?? 0} coins'),
                          Text('Rating: ${profile?.rating ?? 1200}'),
                        ],
                      );
                    },
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
                  },
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('Wallet'),
                )
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.2,
                children: [
                  _HomeCard(
                    title: 'Play vs AI',
                    subtitle: 'Practice with adjustable depth',
                    icon: Icons.smart_toy,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChessScreen(singlePlayer: true))),
                  ),
                  _HomeCard(
                    title: 'Host Bet Match',
                    subtitle: 'Create a room, set a wager',
                    icon: Icons.sports_martial_arts,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BetMatchScreen(host: true))),
                  ),
                  _HomeCard(
                    title: 'Join Bet Room',
                    subtitle: 'Enter a code to challenge',
                    icon: Icons.meeting_room,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BetMatchScreen(host: false))),
                  ),
                  _HomeCard(
                    title: 'Online Lobby',
                    subtitle: 'Quick casual matches',
                    icon: Icons.public,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineLobbyScreen())),
                  ),
                  _HomeCard(
                    title: 'Profile',
                    subtitle: 'Edit username & stats',
                    icon: Icons.person,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
