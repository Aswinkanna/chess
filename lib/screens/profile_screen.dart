import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  bool _saving = false;

  Future<void> _save(String uid) async {
    setState(() => _saving = true);
    await UserService.instance.updateDisplayName(uid, _nameCtrl.text.trim());
    await FirebaseAuth.instance.currentUser?.updateDisplayName(_nameCtrl.text.trim());
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<UserProfile?>(
          stream: UserService.instance.watchProfile(user.uid),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            if (profile != null && _nameCtrl.text.isEmpty) {
              _nameCtrl.text = profile.displayName;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${user.email}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Display name'),
                ),
                const SizedBox(height: 20),
                Text('Balance: ${profile?.balance ?? 0} coins'),
                Text('Rating: ${profile?.rating ?? 1200}'),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : () => _save(user.uid),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

