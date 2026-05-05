import 'package:flutter/material.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Refer & Earn 👥")),
      body: const Center(
        child: Text("Referral Screen", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}