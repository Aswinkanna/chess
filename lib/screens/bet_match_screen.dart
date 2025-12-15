import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../services/user_service.dart';
import 'chess_screen.dart';

class BetMatchScreen extends StatefulWidget {
  final bool host;
  const BetMatchScreen({super.key, required this.host});

  @override
  State<BetMatchScreen> createState() => _BetMatchScreenState();
}

class _BetMatchScreenState extends State<BetMatchScreen> {
  final _roomCtrl = TextEditingController();
  final _betCtrl = TextEditingController(text: '100');
  String _color = 'white';

  @override
  void initState() {
    super.initState();
    if (widget.host) {
      _roomCtrl.text = const Uuid().v4().substring(0, 6).toUpperCase();
    }
  }

  void _startMatch() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final roomId = _roomCtrl.text.trim();
    final bet = int.tryParse(_betCtrl.text.trim()) ?? 0;
    UserService.instance.adjustBalance(user.uid, -bet);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChessScreen(
          singlePlayer: false,
          online: true,
          roomId: roomId,
          host: widget.host,
          bet: bet,
          localColor: _color,
          userId: user.uid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.host ? 'Host bet match' : 'Join bet match'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: FirebaseAuth.instance.currentUser == null
              ? null
              : UserService.instance.watchProfile(FirebaseAuth.instance.currentUser!.uid),
          builder: (context, snapshot) {
            final balance = snapshot.data?.balance ?? 0;
            final bet = int.tryParse(_betCtrl.text.trim()) ?? 0;
            final canPlay = balance >= bet;
            return Column(
              children: [
                Text('Balance: $balance coins'),
                const SizedBox(height: 12),
                TextField(
                  controller: _roomCtrl,
                  readOnly: widget.host,
                  decoration: const InputDecoration(labelText: 'Room code'),
                ),
                const SizedBox(height: 12),
                if (widget.host)
                  TextField(
                    controller: _betCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Bet amount (coins)'),
                    onChanged: (_) => setState(() {}),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Your color:'),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('White'),
                      selected: _color == 'white',
                      onSelected: (_) => setState(() => _color = 'white'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Black'),
                      selected: _color == 'black',
                      onSelected: (_) => setState(() => _color = 'black'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: canPlay ? _startMatch : null,
                    label: Text(widget.host ? 'Create & play' : 'Join & play'),
                  ),
                ),
                if (!canPlay)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text('Not enough coins', style: TextStyle(color: Colors.redAccent)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

